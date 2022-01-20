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

      nodes = @game.graph.connected_nodes(corporation).keys.sort_by do |node|
        revenue = @game.route_trains(corporation)
          .map { |train| node.route_revenue(@game.phase, train) }
          .max
        [
          node.tokened_by?(corporation) ? 0 : 1,
          node.offboard? ? 0 : 1,
          -revenue,
        ]
      end

      now = Time.now

      skip_paths = static.flat_map(&:paths).to_h { |path| [path, true] }

      nodes.each do |node|
        if Time.now - now > path_timeout
          puts 'Path timeout reached'
          break
        else
          puts "Path search: #{nodes.index(node)} / #{nodes.size}"
        end

        node.walk(corporation: corporation, skip_paths: skip_paths) do |_, vp|
          paths = vp.keys

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

          connections[id] = chains.map do |c|
            { left: c[:nodes][0], right: c[:nodes][1], chain: c }
          end
        end
      end

      puts "Found #{connections.size} paths in: #{Time.now - now}"
      puts 'Pruning paths to legal routes'

      now = Time.now
      train_routes = Hash.new { |h, k| h[k] = [] }
      connections.each do |_, connection|
        @game.route_trains(corporation).each do |train|
          route = Engine::Route.new(
            @game,
            @game.phase,
            train,
            connection_data: connection,
          )
          route.revenue
          train_routes[train] << route
        rescue GameError # rubocop:disable Lint/SuppressedException
        end
      end
      puts "Pruned paths to #{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} in: #{Time.now - now}"

      static.each { |route| train_routes[route.train] = [route] }

      train_routes.each do |train, routes|
        train_routes[train] = routes.sort_by(&:revenue).reverse.take(route_limit)
      end

      train_routes = train_routes.values.sort_by(&:size)

      combos = [[]]
      possibilities = []

      limit = train_routes.map(&:size).reduce(&:*)
      puts "Finding route combos with depth #{limit}"
      counter = 0
      now = Time.now

      train_routes.each do |routes|
        combos = routes.flat_map do |route|
          combos.map do |combo|
            combo += [route]
            route.routes = combo
            route.clear_cache!(only_routes: true)
            counter += 1
            if (counter % 1000).zero?
              puts "#{counter} / #{limit}"
              raise if Time.now - now > route_timeout
            end

            route.revenue
            possibilities << combo
            combo
          rescue GameError # rubocop:disable Lint/SuppressedException
          end
        end

        combos.compact!
      rescue RuntimeError
        puts 'Route timeout reach'
        break
      end

      puts "Found #{possibilities.size} possible route combos in: #{Time.now - now}"

      max_routes = possibilities.max_by do |routes|
        routes.each { |route| route.routes = routes }
        @game.routes_revenue(routes)
      end || []

      max_routes.each { |route| route.routes = max_routes }
    end

    ############################
    ######### testing ##########
    ############################

    def test_compute(corporation, **opts)
      static = opts[:routes] || []
      path_timeout = opts[:path_timeout] || 20
      route_timeout = opts[:route_timeout] || 20
      route_limit = opts[:route_limit] || 1_000
      use_js_algorithm = opts[:use_js_algorithm] || false

      connections = {}
      # Sort trains longest first, in case that improves combo calculations (some spotty evidence that it might)
      # trains = @game.route_trains(corporation).sort_by {|train| -train.distance}
      # HACK: sort by train price, since some trains have multiple distance portions - or could add them?
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

      # Add a per-node timeout to ensure we don't spend ALL time on first node's paths (in huge maps), which can cause
      # all train routes to conflict with each other
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
      # route_bitfields = Hash.new { |h, k| h[k] = [] } # map of train to bitfield

      # table of bit 0-31 to bitmask
      bit_to_bitmask = []
      mask = 1
      i = 0
      while i < 32
        bit_to_bitmask[i] = mask
        mask <<= 1
        i += 1
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
        abort_count = 0
        skipped_mirror_routes = 0
        route_counter.each { |train, _| route_counter[train] = 0 }
        # bitfield = []
        node_abort = false

        node.walk(corporation: corporation, skip_paths: skip_paths) do |_, vp|
          next if node_abort

          paths = vp.keys

          abort = nil
          walk_counter += 1

          if Time.now - node_now > node_timeout
            # puts ' Node timeout reached'
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
          # bitfield = []

          complete = lambda do
            # assemble connection's bitfield one hexside at a time
            # TODO: this misses some hex connections for some reason
            # if (left != right) && (left.hex != right.hex) # not sure why left == right is possible, or in two ways!
            #   set_bit(bitfield, bitFromHexes(left, right, hexside_bits), bit_to_bitmask)
            # end

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
              # TODO: working to remove this (move up into prior loop so don't walk loop again)
              bitfield = bitfield_from_connection(connection, hexside_bits, bit_to_bitmask)

              # exclude this route if a duplicate or mirror is already present
              # NOTE: the mirror check is cpu intensive currently, and there aren't that many mirror routes found,
              #  so it's faster to just add mirror routes to the collections and run them through the combo generator
              # if tableContainsBitfield(route_bitfields[train], bitfield)
              # skipped_mirror_routes += 1
              # else
              route = Engine::Route.new(
                @game,
                @game.phase,
                train,
                connection_data: connection,
                bitfield: bitfield,
              )
              # route_bitfields[train] << bitfield

              route.revenue # raises various errors if bad route
              train_routes[train] << route
              route_counter[train] += 1
              # end
            end

          # These all result in the route not being added to train_routes[train],
          # but the nature of the error determines how to continue or terminate processing of the connection path
          rescue RouteTooLong
            # ignore for this train, and abort walking this path if ignored for all trains
            path_abort[train] = true # path is dead for this train
            if path_abort.values.all?
              abort_count += 1
              abort = :abort # this path is dead for all trains, don't walk it further
            end
          rescue NoToken, RouteTooShort
            # keep extending this connection set
          rescue ReusesCity, RouteBlocked
            abort = :abort # this path is dead, don't walk it further
          rescue GameError => e
            # an unhandled route error that probably needs handling
            puts e
          end
          abort
        end
        puts ' Node timeout reached' if node_abort
        puts " node.walk iterated #{walk_counter} times, built #{counter} connections, skipped #{skipped_mirror_routes} "\
             "mirror routes, added routes #{route_counter.map { |k, v| k.name + ':' + v.to_s }.join(', ')}, "\
             "and aborted #{abort_count} path branches"
      end

      # Check that there are no duplicate hexside bits(algorithm error)
      mismatch = hexside_bits.length - hexside_bits.uniq.length
      puts "  ERROR: hexside_bits contains #{mismatch} duplicate bits" if mismatch != 0
      maxbit = hexside_bits.map { |_hexside, bit| bit }.max + 1
      puts "Evaluated #{connections.size} paths, found #{maxbit} unique hexsides, and found valid routes "\
           "#{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} in: #{Time.now - now}"

      static.each { |route| train_routes[route.train] = [route] }

      train_routes.each do |train, routes|
        train_routes[train] = routes.sort_by(&:revenue).reverse.take(route_limit)
      end

      # Code Review note:
      # Sorting by route array size has intermittent problems if the longer train has fewer routes, like if I limit the first
      # train's routes.  A suboptimal combo revenue is found in some test scenarios.
      # Regardless of whether that first-train constraint is kept or discarded, sorting by array size here could be a latent bug;
      # perhaps if all train's routes are limited to route_limit, the sort order of ties may be unpredictable.
      # I'd rather sort by train size, which I assume was the original intent.
      # sorted_routes = train_routes.values.sort_by(&:size)
      sorted_routes = train_routes.map { |_train, routes| routes } # already in train order from above

      limit = sorted_routes.map(&:size).reduce(&:*)
      puts "Finding route combos of best #{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} "\
           "routes with depth #{limit}"

      if use_js_algorithm # rubocop:disable Style/ConditionalAssignment
        possibilities = js_evaluate_combos(sorted_routes, route_timeout)
      else
        possibilities = evaluate_combos(sorted_routes, route_timeout)
      end

      # final sanity check on best combos: recompute each route.revenue in case it needs to reject a combo
      bad_route = nil
      print_hexside_bits = false
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
        puts "   route: #{bad_route.connection_hexes.map { |hex| hex }.join('-')}"
        puts '   combo routes by hex:'
        routes.each do |route|
          puts "          #{route.connection_hexes.map { |hex| hex }.join('-')}" # if route != bad_route
        end
        # puts '   combo routes by edge:'
        # routes.each do |route|
        #   edgelist = route.connection_data.map { |conn| conn[:left].paths[0].edges[0].id + ' - ' +
        #              conn[:left].paths[1].edges[0].id }.join(' - ')
        #   # + '-' + conn[:right].paths[0].edges[0].id + '-' + conn[:right].paths[1].edges[0].id
        #   puts "          #{edgelist}" # if route != bad_route
        # end

        testcombo = routes - [bad_route]
        conflict = route_bitfield_conflicts(testcombo, bad_route)
        puts "   route_bitfield_conflicts(combo,bad_route) = #{conflict}"
        if RUBY_ENGINE == 'opal'
          js_conflict = false # rubocop:disable Lint/UselessAssignment
          %x(
          let js_bad_route =  { route: bad_route, bitfield: bad_route.bitfield };
          let js_routes = [];
          Opal.send(testcombo, 'each', [], function(rb_route)
          {
            js_routes.push( { route: rb_route, bitfield: rb_route.bitfield } );
          });
          let js_combo = { routes: js_routes };

          js_conflict = js_route_bitfield_conflicts(js_combo, js_bad_route);

          let js_mismatch = js_conflict != conflict;
          console.log("   js_route_bitfield_conflicts(combo,bad_route) = " + js_conflict + (js_mismatch ? "  <== PROBLEM" : ""));
          if (js_mismatch)
          {
            let js_full_combo = { routes: js_routes };
            js_full_combo.routes.push(js_bad_route);
            print_combo(js_full_combo);
          }
          )
        end
        # print_hexside_bits = true
        routes # include bad combo in the result set
      end || []

      if print_hexside_bits
        puts '  hexside_bits map:'
        hexside_bits.map do |hexside, bit|
          puts "    #{bit}  #{hexside}"
        end
      end

      max_routes.each { |route| route.routes = max_routes }
    end

    #
    # The Ruby algorithm
    #
    def evaluate_combos(sorted_routes, route_timeout)
      combos = [[]]
      possibilities = []

      limit = sorted_routes.map(&:size).reduce(&:*)
      counter = 0
      max_revenue = 0
      possibilities_count = 0
      conflicts = 0
      now = Time.now

      sorted_routes.each do |routes|
        combos = routes.flat_map do |route|
          combos.map do |combo|
            counter += 1
            if (counter % 50_000).zero?
              puts "#{counter} / #{limit}"
              raise if Time.now - now > route_timeout
            end
            if route_bitfield_conflicts(combo, route)
              conflicts += 1
            else
              combo += [route]
              route.routes = combo
              route.clear_cache!(only_routes: true)

              possibilities_count += 1
              # route.revenue     # throws GameError if routes in the combo conflict
              route.auto_router_revenue # simple revenue calc without route validity checks
              combo_revenue = @game.routes_revenue(combo)

              # accumulate best-value routes, or start over if found a bigger best
              if combo_revenue >= max_revenue
                if combo_revenue > max_revenue
                  possibilities.clear
                  max_revenue = combo_revenue
                  # puts "  new max_revenue found $#{max_revenue}"
                end
                possibilities << combo
              end
              combo
            end
          rescue GameError => e
            puts " route.auto_router_revenue rejected a conflicting route - SHOULD NEVER HAPPEN - #{e}"
          end
        end

        combos.compact!
      rescue RuntimeError
        puts 'Route timeout reached'
        break
      end

      puts "Found #{possibilities_count} possible combos (#{possibilities.size} best) and rejected #{conflicts} "\
           "conflicting combos in: #{Time.now - now}"
      possibilities
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
          # micro-optimized ruby gives much faster opal code
          node1 = node2
          node2 = paths[index]
          case node1.edges.size
          when 1
            # node1 has 1 edge, connect it to first edge of next node
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

          # TODO: this doesn't work in all cases
          # node1_id = node1.edges[0].id # node1.hex.coordinates
          # node2_id = node2.edges[0].id # node2.hex.coordinates
          # hexside = node1_id + '-' + node2_id
          # if (hexside_bits.include?(hexside))
          #   set_bit(bitfield, hexside_bits[hexside], bit_to_bitmask)
          # else
          #   # try the reverse direction (same hexside)
          #   reverse = node2_id + '-' + node1_id
          #   puts "  Error? hexside == reverse!  #{hexside}, #{reverse}" if hexside == reverse
          #   if (hexside_bits.include?(reverse))
          #     set_bit(bitfield, hexside_bits[reverse], bit_to_bitmask)
          #   else
          #     #bit = hexside_bits.size / 2 # there are two entries for each bit, forward and reverse
          #     bit = hexside_bits.length > 0 ? hexside_bits.map {|hexside, bit| bit}.max() + 1 : 0
          #     #puts " bitfield_from_connection adding bit #{newbit} for #{hexside} and #{reverse}"
          #     hexside_bits[hexside] = bit
          #     hexside_bits[reverse] = bit
          #     set_bit(bitfield, bit, bit_to_bitmask)
          #   end
          # end
          index += 1
        end
      end
      bitfield
    end

    # helper to try fwd and rev combinations of hexside connections
    def check_and_set(bitfield, hexside_left, hexside_right, hexside_bits, bit_to_bitmask)
      # NOTE: now that we're testing edges, each edge IS a hexside, so left and right are simply different hexsides
      # always check them both
      check_edge_and_set(bitfield, hexside_left, hexside_bits, bit_to_bitmask)
      check_edge_and_set(bitfield, hexside_right, hexside_bits, bit_to_bitmask)

      # OLD: left and right as two hexes that connect
      # hexside = hexside_left + '-' + hexside_right
      # if (hexside_bits.include?(hexside))
      #   set_bit(bitfield, hexside_bits[hexside], bit_to_bitmask)
      # else
      #   # try the reverse direction (same hexside)
      #   reverse = hexside_right + '-' + hexside_left
      #   puts "  Error? hexside == reverse!  #{hexside}, #{reverse}" if hexside == reverse
      #   if (hexside_bits.include?(reverse))
      #     set_bit(bitfield, hexside_bits[reverse], bit_to_bitmask)
      #   else
      #     #bit = hexside_bits.size / 2 # there are two entries for each bit, forward and reverse
      #     bit = hexside_bits.length > 0 ? hexside_bits.map {|hexside, bit| bit}.max() + 1 : 0
      #     #puts " bitfield_from_connection adding bit #{bit} for #{hexside} and #{reverse}"
      #     hexside_bits[hexside] = bit
      #     hexside_bits[reverse] = bit
      #     set_bit(bitfield, bit, bit_to_bitmask)
      #   end
      # end
    end

    def check_edge_and_set(bitfield, hexside_edge, hexside_bits, bit_to_bitmask)
      if hexside_bits.include?(hexside_edge)
        set_bit(bitfield, hexside_bits[hexside_edge], bit_to_bitmask)
      else
        # newbit = hexside_bits.size / 2 # there are two entries for each bit, forward and reverse
        newbit = hexside_bits.length.positive? ? hexside_bits.map { |_hexside, bit| bit }.max + 1 : 0
        # puts " bitfield_from_connection adding bit #{bit} for #{hexside_edge}"
        hexside_bits[hexside_edge] = newbit
        hexside_bits[hexside_edge] = newbit
        set_bit(bitfield, newbit, bit_to_bitmask)
      end
    end

    # NOTE: keeping around until decide if can abandon bitfield search in complete lambda
    # def bitFromHexes(node1, node2, hexside_bits)
    #   fromHex = node1.hex.coordinates
    #   toHex = node2.hex.coordinates
    #   bit = 0
    #   hexside = fromHex + toHex
    #   if (hexside_bits.include?(hexside))
    #     bit = hexside_bits[hexside]
    #   else
    #     # try the reverse direction
    #     reverse = toHex  + fromHex
    #     if (hexside_bits.include?(reverse))
    #       bit = hexside_bits[reverse]
    #     else
    #       bit = hexside_bits.size / 2 # there are two entries for each bit, forward and reverse
    #       #puts " bitFromHexes adding bit #{bit} for #{hexside} and #{reverse}"
    #       hexside_bits[hexside] = bit
    #       hexside_bits[reverse] = bit
    #     end
    #   end
    #   bit
    # end

    # bitfield is an array of integers, can be expanded by this call if necessary
    # bit is a bit number, 0 is lowest bit, 32 will jump to the next int in the array, and so on
    def set_bit(bitfield, bit, bit_to_bitmask)
      entry = (bit / 32).to_i # which array entry do we need
      mask = bit_to_bitmask[bit & 31] # which bit in that int to set
      add_count = entry + 1 - bitfield.size
      while add_count.positive?
        bitfield << 0 # add a new integer to the array
        add_count -= 1
      end
      bitfield[entry] |= mask
    end

    # does testroute's bitfield conflict with any other routes in the combo?
    def route_bitfield_conflicts(combo, testroute)
      combo.each do |route|
        # each route has 1 or more ints in bitfield array
        # only test up to the shorter size, since bits beyond that obviously don't conflict
        index = [route.bitfield.size, testroute.bitfield.size].min - 1
        while index >= 0
          return true if (route.bitfield[index] & testroute.bitfield[index]) != 0

          index -= 1
        end

        # ruby makes array comparison easier, hopefully with faster opal result
        # NO - this is incorrect if sizes are different
        # index = 0
        # while index < testroute.bitfield.size do
        #   return true if (route.bitfield[index] & testroute.bitfield[index]) != 0
        #   index += 1
        # end
      end
      false
    end

    # NOTE: keeping in case finding mirror routes becomes worthwhile
    # # does test bitfield equal any other bitfields in the table?
    # def tableContainsBitfield(table, testbitfield)
    #   #slower
    #   #table.map{|bitfield| bitfield == testbitfield}.reduce(:|)

    #   #also slow
    #   table.any?{|bitfield| bitfield == testbitfield}

    #   # faster but still slow
    #   # table.each do |bitfield|
    #   #   if (bitfield == testbitfield)
    #   #     return true
    #   #   end
    #   # end
    #   # false
    # end

    #
    # The js-in-Opal algorithm
    #
    def js_evaluate_combos(rb_sorted_routes, _route_timeout)
      rb_possibilities = []
      possibilities_count = 0
      conflicts = 0
      limit = rb_sorted_routes.map(&:size).reduce(&:*) # rubocop:disable Lint/UselessAssignment
      now = Time.now

      if RUBY_ENGINE == 'opal'
        puts '** Using javascript combo-generator **'
        %x(
        let possibilities = []
        let combos = [];
        let counter = 0;
        let max_revenue = 0;

        //
        // marshal Opal objects to js for faster/easier access
        //
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

        //
        // init combos with first train's routes
        //
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
              //console.log("  new max_revenue found $" + max_revenue);
            }
            possibilities.push(combo);
          }
        }

        //
        // generate combos with remaining trains' routes
        //
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
                    //console.log("  new max_revenue found $" + max_revenue);
                  }
                  possibilities.push(newcombo);
                }
              }
            }
          }
          new_combos.forEach((combo, n) => { combos.push(combo) });
        }

        //
        // marshall best combos back to Opal
        //
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
        puts '** javascript combo-generator requested but not running in Opal environment - no combos computed **'
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
          {
            //console.log("  route/combo conflict:");
            //console.log("    testroute:    " + format_bitfield(testroute.bitfield));
            //print_combo(combo)

            return true;
          }
          index -= 1;
        }
      }
      return false;
    }

    function print_combo(combo)
    {
      console.log("    combo routes: " + format_bitfield(combo.routes[0].bitfield));
      for (var i=1; i < combo.routes.length; i++)
        console.log("                  " + format_bitfield(combo.routes[i].bitfield));
    }

    function format_bitfield(bitfield)
    {
      let binary = "";
      let numbers = "";
      for (var word=0; word < bitfield.length; word++)
      {
        if (word > 0)
          numbers += ", ";
        numbers +=  bitfield[word];
        let field = (bitfield[word] >>> 0).toString(2);     // >>> 0 coerces to unsigned number if high bit set
        field = "00000000000000000000000000000000".substr(field.length) + field;  // pad to 32 bits
        binary += " " + field;
      }
      return binary + " (" + numbers + ")";
    }
    )
  end
end
