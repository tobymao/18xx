# frozen_string_literal: true

require_relative 'game_error'
require_relative 'route'

module Engine
  class AutoRouter
    def initialize(game, flash = nil)
      @game = game
      @next_hexside_bit = 0
      @flash = flash
    end

    def compute(corporation, **opts)
      static = opts[:routes] || []
      path_timeout = opts[:path_timeout] || 30
      route_timeout = opts[:route_timeout] || 10
      route_limit = opts[:route_limit] || 10_000

      connections = {}
      trains = @game.route_trains(corporation).sort_by(&:price).reverse

      graph = @game.graph_for_entity(corporation)
      nodes = graph.connected_nodes(corporation).keys.sort_by do |node|
        revenue = trains
          .map { |train| node.route_revenue(@game.phase, train) }
          .max
        [
          node.tokened_by?(corporation) ? 0 : 1,
          node.offboard? ? 0 : 1,
          -revenue,
        ]
      end

      path_walk_timed_out = false
      now = Time.now

      skip_paths = static.flat_map(&:paths).to_h { |path| [path, true] }
      # if only routing for subset of trains, omit the trains we won't assemble routes for
      skip_trains = static.flat_map(:train).to_a
      trains -= skip_trains

      train_routes = Hash.new { |h, k| h[k] = [] }    # map of train to route list
      hexside_bits = Hash.new { |h, k| h[k] = 0 }     # map of hexside_id to bit number
      @next_hexside_bit = 0

      nodes.each do |node|
        if Time.now - now > path_timeout
          puts 'Path timeout reached'
          path_walk_timed_out = true
          break
        else
          puts "Path search: #{nodes.index(node)} / #{nodes.size} - paths starting from #{node.hex.name}"
        end

        walk_corporation = graph.no_blocking? ? nil : corporation
        node.walk(corporation: walk_corporation, skip_paths: skip_paths) do |_, vp|
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

          # a 1-city Local train will have no chains but will have a left; route.revenue will reject if not valid for game
          if chains.empty?
            next unless left

            chains << { nodes: [left, nil], paths: [] }
          end

          id = chains.flat_map { |c| c[:paths] }.sort!
          next if connections[id]

          connections[id] = chains.map do |c|
            { left: c[:nodes][0], right: c[:nodes][1], chain: c }
          end

          connection = connections[id]

          # each train has opportunity to vote to abort a branch of this node's path-walk tree
          path_abort = trains.to_h { |train| [train, true] }

          # build a test route for each train, use route.revenue to check for errors, keep the good ones
          trains.each  do |train|
            route = Engine::Route.new(
              @game,
              @game.phase,
              train,
              connection_data: connection,
              bitfield: bitfield_from_connection(connection, hexside_bits),
            )
            route.routes = [route]
            route.revenue(suppress_check_other: true) # defer route-collection checks til later
            train_routes[train] << route
          rescue RouteTooLong
            # ignore for this train, and abort walking this path if ignored for all trains
            path_abort.delete(train)
          rescue ReusesCity
            path_abort.clear
          rescue NoToken, RouteTooShort, GameError # rubocop:disable Lint/SuppressedException
          end

          next :abort if path_abort.empty?
        end
      end

      # Check that there are no duplicate hexside bits (algorithm error)
      puts "Evaluated #{connections.size} paths, found #{@next_hexside_bit} unique hexsides, and found valid routes "\
           "#{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} in: #{Time.now - now}"

      static.each do |route|
        # recompute bitfields of passed-in routes since the bits may have changed across auto-router runs
        route.bitfield = bitfield_from_connection(route.connection_data, hexside_bits)
        train_routes[route.train] = [route] # force this train's route to be the passed-in one
      end

      train_routes.each do |train, routes|
        train_routes[train] = routes.sort_by(&:revenue).reverse.take(route_limit)
      end

      sorted_routes = train_routes.map { |_train, routes| routes }

      limit = sorted_routes.map(&:size).reduce(&:*)
      puts "Finding route combos of best #{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} "\
           "routes with depth #{limit}"

      now = Time.now
      possibilities = js_evaluate_combos(sorted_routes, route_timeout)

      if path_walk_timed_out
        @flash&.call('Auto route path walk failed to complete (PATH TIMEOUT)')
      elsif Time.now - now > route_timeout
        @flash&.call('Auto route selection failed to complete (ROUTE TIMEOUT)')
      end

      # final sanity check on best combos: recompute each route.revenue in case it needs to reject a combo
      max_routes = possibilities.max_by do |routes|
        routes.each do |route|
          route.clear_cache!(only_routes: true)
          route.routes = routes
          route.revenue
        end
        @game.routes_revenue(routes)
      rescue GameError => e
        # report error but still include combo with errored route in the result set
        puts " Sanity check error, likely an auto_router bug: #{e}"
        routes
      end || []

      max_routes.each { |route| route.routes = max_routes }
    end

    # inputs:
    #   connection is a route's connection_data
    #   hexside_bits is a map of hexside_id to bit number
    # returns:
    #   the bitfield (array of ints) representing all hexsides in the connection path
    # updates:
    #   new hexsides are added to hexside_bits
    def bitfield_from_connection(connection, hexside_bits)
      bitfield = [0]
      connection.each do |conn|
        paths = conn[:chain][:paths]
        if paths.size == 1 # special case for tiny intra-tile path like in 18NewEngland (issue #6890)
          hexside_left = paths[0].nodes[0].id
          check_edge_and_set(bitfield, hexside_left, hexside_bits)
          if paths[0].nodes.size > 1 # local trains may not have a second node
            hexside_right = paths[0].nodes[1].id
            check_edge_and_set(bitfield, hexside_right, hexside_bits)
          end
        else
          (paths.size - 1).times do |index|
            # hand-optimized ruby gives faster opal code
            node1 = paths[index]
            node2 = paths[index + 1]
            case node1.edges.size
            when 1
              # node1 has 1 edge, connect it to first edge of node2
              hexside_left = node1.edges[0].id
              hexside_right = node2.edges[0].id
              check_and_set(bitfield, hexside_left, hexside_right, hexside_bits)
            when 2
              # node1 has 2 edges, connect them as well as 2nd edge to first node2 edge
              hexside_left = node1.edges[0].id
              hexside_right = node1.edges[1].id
              check_and_set(bitfield, hexside_left, hexside_right, hexside_bits)
              hexside_left = hexside_right
              hexside_right  = node2.edges[0].id
              check_and_set(bitfield, hexside_left, hexside_right, hexside_bits)
            else
              puts "  ERROR: auto-router found unexpected number of path node edges #{node1.edges.size}. "\
                   'Route combos may be be incorrect'
            end
          end
        end
      end
      bitfield
    end

    def check_and_set(bitfield, hexside_left, hexside_right, hexside_bits)
      check_edge_and_set(bitfield, hexside_left, hexside_bits)
      check_edge_and_set(bitfield, hexside_right, hexside_bits)
    end

    def check_edge_and_set(bitfield, hexside_edge, hexside_bits)
      if hexside_bits.include?(hexside_edge)
        set_bit(bitfield, hexside_bits[hexside_edge])
      else
        hexside_bits[hexside_edge] = @next_hexside_bit
        set_bit(bitfield, @next_hexside_bit)
        @next_hexside_bit += 1
      end
    end

    # bitfield is an array of integers, can be expanded by this call if necessary
    # bit is a bit number, 0 is lowest bit, 32 will jump to the next int in the array, and so on
    def set_bit(bitfield, bit)
      entry = (bit / 32).to_i
      mask = 1 << (bit & 31)
      add_count = entry + 1 - bitfield.size
      while add_count.positive?
        bitfield << 0
        add_count -= 1
      end
      bitfield[entry] |= mask
    end

    # The js-in-Opal algorithm
    def js_evaluate_combos(_rb_sorted_routes, _route_timeout)
      rb_possibilities = []
      possibilities_count = 0
      conflicts = 0
      now = Time.now

      %x{
        let possibilities = []
        let combos = []
        let counter = 0
        let max_revenue = 0
        let js_now = Date.now()
        let js_route_timeout = _route_timeout * 1000

        // marshal Opal objects to js for faster/easier access
        const js_sorted_routes = []
        let limit = 1
        Opal.send(_rb_sorted_routes, 'each', [], function(rb_routes) {
          let js_routes = []
          limit *= rb_routes.length
          Opal.send(rb_routes, 'each', [], function(rb_route)
          {
            js_routes.push( { route: rb_route, bitfield: rb_route.bitfield, revenue: rb_route.revenue } )
          })
          js_sorted_routes.push(js_routes)
        })
        let old_limit = limit

        // init combos with first train's routes
        for (r=0; r < js_sorted_routes[0].length; r++) {
          const route = js_sorted_routes[0][r]
          counter += 1
          combo = { revenue: route.revenue, routes: [route] }
          combos.push(combo) // save combo for later extension even if not yet a valid combo

          if (is_valid_combo(combo))
          {
            possibilities_count += 1

            // accumulate best-value combos, or start over if found a bigger best
            if (combo.revenue >= max_revenue) {
              if (combo.revenue > max_revenue) {
                possibilities = []
                max_revenue = combo.revenue
              }
              possibilities.push(combo)
            }
          }
        }

        continue_looking = true
        // generate combos with remaining trains' routes
        for (let train=1; continue_looking && (train < js_sorted_routes.length); train++) {
          // Recompute limit, since by 3rd train it will start going down as invalid combos are excluded from the test set
          // revised limit = combos.length * remaining train route lengths
          limit = combos.length
          for (let remaining=train; remaining < js_sorted_routes.length; remaining++)
            limit *= js_sorted_routes[remaining].length
          if (limit != old_limit) {
            console.log("  adjusting depth to " + limit + " because first " +
                        train + " trains only had " + combos.length + " valid combos")
            old_limit = limit
          }

          let new_combos = []
          for (let rt=0; continue_looking && (rt < js_sorted_routes[train].length); rt++) {
            const route = js_sorted_routes[train][rt]
            for (let c=0; c < combos.length; c++) {
              const combo = combos[c]
              counter += 1
              if ((counter % 1_000_000) == 0) {
                console.log(counter + " / " + limit)
                if (Date.now() - js_now > js_route_timeout) {
                  console.log("Route timeout reached")
                  continue_looking = false
                  break
                }
              }

              if (js_route_bitfield_conflicts(combo, route))
                conflicts += 1
              else {
                // copy the combo, add the route
                let newcombo = { revenue: combo.revenue, routes: [...combo.routes] }
                newcombo.routes.push(route)
                newcombo.revenue += route.revenue
                new_combos.push(newcombo) // save newcombo for later extension even if not yet a valid combo

                if (is_valid_combo(newcombo)) {
                  possibilities_count += 1

                  // accumulate best-value combos, or start over if found a bigger best
                  if (newcombo.revenue >= max_revenue) {
                    if (newcombo.revenue > max_revenue) {
                      possibilities = []
                      max_revenue = newcombo.revenue
                    }
                    possibilities.push(newcombo)
                  }
                }
              }
            }
          }
          new_combos.forEach((combo, n) => { combos.push(combo) })
        }

        // marshall best combos back to Opal
        for (let p=0; p < possibilities.length; p++) {
          const combo = possibilities[p]
          let rb_routes = []
          for (route of combo.routes) {
            rb_routes['$<<'](route.route)
          }
          rb_possibilities['$<<'](rb_routes)
        }
      }

      puts "Found #{possibilities_count} possible combos (#{rb_possibilities.size} best) and rejected #{conflicts} "\
           "conflicting combos in: #{Time.now - now}"
      rb_possibilities
    end

    %x{
      // do final combo validation using game-specific checks driven by
      // route.check_other! that was skipped when building routes
      function is_valid_combo(cb) {
        // temporarily marshall back to opal since we need to call the opal route.check_other!
        let rb_rts = []
        for (let rt of cb.routes) {
          rt.route['$routes='](rb_rts) // allows route.check_other! to process all routes
          rb_rts['$<<'](rt.route)
        }

        // Run route.check_other! for the full combo, to see if game- and action-specific rules are followed.
        // Eg. 1870 destination runs should reject combos that don't have a route from home to destination city
        try {
          for (let rt of cb.routes) {
            rt.route['$check_other!']() // throws if bad combo
          }
          return true
        }
        catch (err) {
          return false
        }
      }

      function js_route_bitfield_conflicts(combo, testroute) {
        for (let cr of combo.routes) {
          // each route has 1 or more ints in bitfield array
          // only test up to the shorter size, since bits beyond that obviously don't conflict
          let index = Math.min(cr.bitfield.length, testroute.bitfield.length) - 1;
          while (index >= 0) {
            if ((cr.bitfield[index] & testroute.bitfield[index]) != 0)
              return true
            index -= 1
          }
        }
        return false
      }
    }
  end
end
