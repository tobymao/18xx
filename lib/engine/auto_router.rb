# frozen_string_literal: true

require_relative 'game_error'
require_relative 'route'

module Engine
  class AutoRouter
    def initialize(game)
      @game = game
    end

    def compute(corporation, **opts)
      static = opts[:routes] || []
      path_timeout = opts[:path_timeout] || 20
      route_timeout = opts[:route_timeout] || 20
      route_limit = opts[:route_limit] || 1_000

      connections = {}
      # Sort trains longest first, in case that improves combo calculations (some spotty evidence that it might)
      # HACK: sort by train price, since some trains have multiple distance portions - or consider adding distance portions
      trains = @game.route_trains(corporation).sort_by { |train| -train.price }

      nodes = @game.graph.connected_nodes(corporation).keys.sort_by do |node|
        revenue = trains
          .map { |train| node.route_revenue(@game.phase, train) }
          .max
        [
          node.tokened_by?(corporation) ? 0 : 1,
          node.offboard? ? 0 : 1,
          -revenue,
        ]
      end

      # Add a per-node timeout to ensure we don't spend ALL time on first node's paths in huge maps,
      # which can cause all train routes to conflict with each other
      node_timeout = path_timeout / nodes.size

      now = Time.now

      skip_paths = static.flat_map(&:paths).to_h { |path| [path, true] }

      train_routes = Hash.new { |h, k| h[k] = [] }    # map of train to route list
      path_abort = Hash.new { |h, k| h[k] = false }   # each train has opportunity to abort a branch of the path walk tree
      route_counter = Hash.new { |h, k| h[k] = 0 }

      trains.each do |train|
        path_abort[train] = false
        route_counter[train] = 0
      end

      hexside_bits = Hash.new { |h, k| h[k] = 0 } # map of hexside_id to bit number

      # table of bit 0-31 to bitmask
      bit_to_bitmask = []
      mask = 1
      (0..31).each do |i|
        bit_to_bitmask[i] = mask
        mask <<= 1
      end

      nodes.each do |node|
        if Time.now - now > path_timeout
          puts 'Path timeout reached'
          break
        else
          puts "Path search: #{nodes.index(node)} / #{nodes.size} - paths starting from #{node.hex.name}"
        end

        node_now = Time.now

        walk_counter = 0
        counter = 0
        route_counter.each { |train, _| route_counter[train] = 0 }
        node_abort = false

        node.walk(corporation: corporation, skip_paths: skip_paths) do |_, vp|
          next if node_abort

          paths = vp.keys

          abort = nil
          walk_counter += 1

          if Time.now - node_now > node_timeout
            # TODO: this is not a complete node.walk abort, find somthing more than :abort but less than break.
            # Or wait til node.walk speed is improved and this may become less important
            abort = :abort
            node_abort = true
          end

          chains = []
          chain = []
          left = nil
          right = nil
          last_left = nil
          last_right = nil

          complete = lambda do
            chains << { nodes: [left, right], paths: chain }
            last_left = left
            last_right = right
            left, right = nil
            chain = []
          end

          assign = lambda do |a, b|
            if a && b
              if a == last_left || b == last_right
                left = b
                right = a
              else
                left = a
                right = b
              end
              complete.call
            elsif !left
              left = a || b
            elsif !right
              right = a || b
              complete.call
            end
          end

          paths.each do |path|
            chain << path
            a, b = path.nodes

            assign.call(a, b) if a || b
          end

          next if chains.empty?

          id = chains.flat_map { |c| c[:paths] }.sort!
          next if connections[id]

          connection = chains.map do |c|
            { left: c[:nodes][0], right: c[:nodes][1], chain: c }
          end
          connections[id] = connection

          counter += 1

          # each train has opportunity to vote to abort a branch of this node's path-walk tree
          path_abort.each { |train, _| path_abort[train] = false }

          # build a test route for each train, use route.revenue to check for errors, keep the good ones
          trains.each do |train|
            unless path_abort[train]
              bitfield = bitfield_from_connection(connection, hexside_bits, bit_to_bitmask)
              route = Engine::Route.new(
                @game,
                @game.phase,
                train,
                connection_data: connection,
                bitfield: bitfield,
              )

              route.revenue # raises various errors if bad route
              train_routes[train] << route
              route_counter[train] += 1
            end

          # These all result in the route not being added to train_routes[train],
          # but the nature of the error determines how to continue or terminate processing of the path walk
          rescue RouteTooLong
            # ignore for this train, and abort walking this path if ignored for all trains
            path_abort[train] = true
            if path_abort.values.all?
              abort = :abort # this path is dead for all trains, don't walk it further
            end
          rescue NoToken, RouteTooShort
            # keep extending this connection set
          rescue ReusesCity, RouteBlocked
            abort = :abort # this path is dead, don't walk it further
          rescue GameError => e
            # an unhandled route error that probably should be handled
            puts e
          end
          abort
        end
        puts ' Node timeout reached' if node_abort
      end

      # Check that there are no duplicate hexside bits (algorithm error)
      mismatch = hexside_bits.length - hexside_bits.uniq.length
      puts "  ERROR: hexside_bits contains #{mismatch} duplicate bits" if mismatch != 0
      maxbit = hexside_bits.map { |_hexside, bit| bit }.max + 1
      puts "Evaluated #{connections.size} paths, found #{maxbit} unique hexsides, and found valid routes "\
           "#{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} in: #{Time.now - now}"

      static.each { |route| train_routes[route.train] = [route] }

      train_routes.each do |train, routes|
        train_routes[train] = routes.sort_by(&:revenue).reverse.take(route_limit)
      end

      sorted_routes = train_routes.map { |_train, routes| routes }

      limit = sorted_routes.map(&:size).reduce(&:*)
      puts "Finding route combos of best #{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} "\
           "routes with depth #{limit}"

      possibilities = js_evaluate_combos(sorted_routes, route_timeout)

      # final sanity check on best combos: recompute each route.revenue in case it needs to reject a combo
      bad_route = nil
      max_routes = possibilities.max_by do |routes|
        routes.each do |route|
          route.clear_cache!(only_routes: true)
          route.routes = routes
          bad_route = route
          route.revenue
        end
        @game.routes_revenue(routes)
      rescue GameError => e
        # report error but still include combo with errored route in the result set
        puts " Sanity check error, likely an auto_router bug: #{e}"
        print_bad_route(routes, bad_route)
        routes
      end || []

      max_routes.each { |route| route.routes = max_routes }
    end

    def print_bad_route(routes, bad_route)
      puts "   route: #{bad_route.connection_hexes.map { |hex| hex }.join('-')}"
      puts '   combo routes by hex:'
      routes.each do |route|
        puts "          #{route.connection_hexes.map { |hex| hex }.join('-')}"
      end
    end

    # inputs:
    #   connection is a route's connection_data
    #   hexside_bits is a map of hexside_id to bit number
    #   bit_to_bitmask is a helper table of bit 0-31 to integer bitmask (essentially 1 << bit)
    # returns:
    #   the bitfield (array of ints) representing all hexsides in the connection path
    # updates:
    #   new hexsides are added to hexside_bits
    def bitfield_from_connection(connection, hexside_bits, bit_to_bitmask)
      bitfield = [0]
      connection.each do |conn|
        paths = conn[:chain][:paths]
        index = 1
        stop = paths.size
        node2 = paths[0]
        while index < stop
          # hand-optimized ruby gives faster opal code
          node1 = node2
          node2 = paths[index]
          case node1.edges.size
          when 1
            # node1 has 1 edge, connect it to first edge of node2
            hexside_left = node1.edges[0].id
            hexside_right = node2.edges[0].id
            check_and_set(bitfield, hexside_left, hexside_right, hexside_bits, bit_to_bitmask)
          when 2
            # node1 has 2 edges, connect them as well as 2nd edge to first node2 edge
            hexside_left = node1.edges[0].id
            hexside_right = node1.edges[1].id
            check_and_set(bitfield, hexside_left, hexside_right, hexside_bits, bit_to_bitmask)
            hexside_left = hexside_right
            hexside_right  = node2.edges[0].id
            check_and_set(bitfield, hexside_left, hexside_right, hexside_bits, bit_to_bitmask)
          else
            puts "  ERROR: auto-router found unexpected number of path node edges #{node1.edges.size}. "\
                 'Route combos may be be incorrect'
          end
          index += 1
        end
      end
      bitfield
    end

    def check_and_set(bitfield, hexside_left, hexside_right, hexside_bits, bit_to_bitmask)
      check_edge_and_set(bitfield, hexside_left, hexside_bits, bit_to_bitmask)
      check_edge_and_set(bitfield, hexside_right, hexside_bits, bit_to_bitmask)
    end

    def check_edge_and_set(bitfield, hexside_edge, hexside_bits, bit_to_bitmask)
      if hexside_bits.include?(hexside_edge)
        set_bit(bitfield, hexside_bits[hexside_edge], bit_to_bitmask)
      else
        newbit = hexside_bits.length.positive? ? hexside_bits.map { |_hexside, bit| bit }.max + 1 : 0
        hexside_bits[hexside_edge] = newbit
        set_bit(bitfield, newbit, bit_to_bitmask)
      end
    end

    # bitfield is an array of integers, can be expanded by this call if necessary
    # bit is a bit number, 0 is lowest bit, 32 will jump to the next int in the array, and so on
    def set_bit(bitfield, bit, bit_to_bitmask)
      entry = (bit / 32).to_i
      mask = bit_to_bitmask[bit & 31]
      add_count = entry + 1 - bitfield.size
      while add_count.positive?
        bitfield << 0
        add_count -= 1
      end
      bitfield[entry] |= mask
    end

    # does testroute conflict with any route in the combo?
    def route_bitfield_conflicts(combo, testroute)
      combo.each do |route|
        # only test up to the shorter size, since bits beyond that obviously don't conflict
        index = [route.bitfield.size, testroute.bitfield.size].min - 1
        while index >= 0
          return true if (route.bitfield[index] & testroute.bitfield[index]) != 0

          index -= 1
        end
      end
      false
    end

    # The js-in-Opal algorithm
    def js_evaluate_combos(rb_sorted_routes, _route_timeout)
      rb_possibilities = []
      possibilities_count = 0
      conflicts = 0
      limit = rb_sorted_routes.map(&:size).reduce(&:*) # rubocop:disable Lint/UselessAssignment
      now = Time.now

      if RUBY_ENGINE == 'opal'
        %x(
        let possibilities = []
        let combos = [];
        let counter = 0;
        let max_revenue = 0;

        // marshal Opal objects to js for faster/easier access
        js_sorted_routes = [];
        Opal.send(rb_sorted_routes, 'each', [], function(rb_routes)
          {
            let js_routes = [];
            Opal.send(rb_routes, 'each', [], function(rb_route)
            {
              js_routes.push( { route: rb_route, bitfield: rb_route.bitfield, revenue: rb_route.revenue } );
            });
            js_sorted_routes.push(js_routes);
          });
        let js_limit = limit

        // init combos with first train's routes
        for (r=0; r < js_sorted_routes[0].length; r++)
        {
          let route = js_sorted_routes[0][r];
          counter += 1;
          combo = { revenue: route.revenue, routes: [route] };
          combos.push(combo);
          possibilities_count += 1;

          // accumulate best-value combos, or start over if found a bigger best
          if (combo.revenue >= max_revenue)
          {
            if (combo.revenue > max_revenue)
            {
              possibilities = []
              max_revenue = combo.revenue;
            }
            possibilities.push(combo);
          }
        }

        // generate combos with remaining trains' routes
        for (train=1; train < js_sorted_routes.length; train++)
        {
          // Recompute limit, since by 3rd train it will start going down as invalid combos are excluded from the test set
          // revised limit = combos.length * remaining train route lengths
          js_limit = combos.length;
          for (var remaining=train; remaining < js_sorted_routes.length; remaining++)
            js_limit *= js_sorted_routes[remaining].length;
          if (js_limit != limit)
            console.log("  adjusting depth to " + js_limit + " because first " +
                        train + " trains only had " + combos.length + " valid combos");

          let new_combos = [];
          for (rt=0; rt < js_sorted_routes[train].length; rt++)
          {
            let route = js_sorted_routes[train][rt];
            for (c=0; c < combos.length; c++)
            {
              let combo = combos[c];
              counter += 1;
              if ((counter % 1_000_000) == 0)
              {
                console.log(counter + " / " + js_limit);
                //TODO: raise if Time.now - now > route_timeout
              }

              if (js_route_bitfield_conflicts(combo, route))
                conflicts += 1;
              else
              {
                possibilities_count += 1;
                // copy the combo, add the route
                let newcombo = { revenue: combo.revenue, routes: [...combo.routes] };
                newcombo.routes.push(route);
                newcombo.revenue += route.revenue;
                new_combos.push(newcombo);

                // accumulate best-value combos, or start over if found a bigger best
                if (newcombo.revenue >= max_revenue)
                {
                  if (newcombo.revenue > max_revenue)
                  {
                    possibilities = []
                    max_revenue = newcombo.revenue;
                  }
                  possibilities.push(newcombo);
                }
              }
            }
          }
          new_combos.forEach((combo, n) => { combos.push(combo) });
        }

        // marshall best combos back to Opal
        for (p=0; p < possibilities.length; p++)
        {
          let combo = possibilities[p];
          let rb_routes = []
          for (route of combo.routes)
          {
            rb_routes['$<<'](route.route);
          }
          rb_possibilities['$<<'](rb_routes);
        }
        )
      else # not Opal
        puts 'Error: javascript combo-generator requested but not running in Opal environment - no combos computed'
      end

      puts "Found #{possibilities_count} possible combos (#{rb_possibilities.size} best) and rejected #{conflicts} "\
           "conflicting combos in: #{Time.now - now}"
      rb_possibilities
    end

    %x(
    function js_route_bitfield_conflicts(combo, testroute)
    {
      for (cr of combo.routes)
      {
        // each route has 1 or more ints in bitfield array
        // only test up to the shorter size, since bits beyond that obviously don't conflict
        let index = Math.min(cr.bitfield.length, testroute.bitfield.length) - 1;
        while (index >= 0)
        {
          if ((cr.bitfield[index] & testroute.bitfield[index]) != 0)
            return true;
          index -= 1;
        }
      }
      return false;
    }
    )
  end
end
