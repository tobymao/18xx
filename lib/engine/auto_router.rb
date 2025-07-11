# frozen_string_literal: true

# backtick_javascript: true

require_relative 'game_error'
require_relative 'route'

module Engine
  class AutoRouter
    attr_accessor :running

    def initialize(game, flash = nil)
      @game = game
      @train_autoroute_group = @game.class::TRAIN_AUTOROUTE_GROUPS
      @next_hexside_bit = 0
      @flash = flash
    end

    def compute(corporation, **opts)
      @running = true
      @route_timeout = opts[:route_timeout] || 10
      trains = @game.route_trains(corporation).sort_by(&:price)
      train_routes, path_walk_timed_out = path(trains, corporation, **opts)
      @flash&.call('Auto route path walk failed to complete (PATH TIMEOUT)') if path_walk_timed_out
      route(train_routes, opts[:callback])
    end

    def route(trains_to_routes, callback)
      %x{
        (new Autorouter(#{self}, #{trains_to_routes}, #{callback})).autoroute();
      }
    end

    def real_revenue(routes)
      routes.each do |route|
        route.clear_cache!(only_routes: true)
        route.routes = routes
        route.revenue
      end
      @game.routes_revenue(routes)
    rescue GameError
      -1
    end

    def path(trains, corporation, **opts)
      static = opts[:routes] || []
      path_timeout = opts[:path_timeout] || 30
      route_limit = opts[:route_limit] || 10_000

      connections = {}

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

      skip_paths = if @train_autoroute_group.nil?
                     static.flat_map(&:paths).to_h { |path| [path, true] }
                   elsif @train_autoroute_group == :each_train_separate
                     # all trains have their own autoroute group so it's not possible to fill skip_paths
                     {}
                   else # rubocop:disable Lint/DuplicateBranch
                     # NOTE: there is room for an optimization here. In the case of TRAIN_AUTOROUTE_GROUP being an array,
                     # we need to compare the train types that are prefilled and the train types that will be searched and
                     # if there is overlap and all the trains that are being searched can't visit the path it can be in skip_path
                     {}
                   end

      # if only routing for subset of trains, omit the trains we won't assemble routes for
      skip_trains = static.flat_map(&:train).to_a
      trains -= skip_trains

      train_routes = Hash.new { |h, k| h[k] = [] }    # map of train to route list
      hexside_bits = Hash.new { |h, k| h[k] = 0 }     # map of hexside_id to bit number
      @next_hexside_bit = 0

      nodes.each do |node|
        if Time.now - now > path_timeout
          LOGGER.debug('Path timeout reached')
          path_walk_timed_out = true
          break
        else
          LOGGER.debug { "Path search: #{nodes.index(node)} / #{nodes.size} - paths starting from #{node.hex.name}" }
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
            chains << { nodes: [left, right], paths: chain, hexes: chain.map(&:hex) }
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

            # use the Local train's 1 city instead of any paths as their key;
            # only 1 train can visit each city, but we want Locals to be able to
            # visit multiple different cities if a corporation has more than one
            # of them
            id = [left]
          else
            id = chains.flat_map { |c| c[:paths] }.sort!
          end

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
              # we have to clone to prevent multiple routes having the same connection array.
              # If we don't clone, then later route.touch_node calls will affect all routes with
              # the same connection array
              connection_data: connection.clone,
              bitfield: bitfield_from_connection(connection, hexside_bits),
            )
            route.routes = [route]
            # defer route combination checks until we have the full combination of routes to check
            route.revenue(suppress_check_route_combination: true)
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
      LOGGER.debug do
        "Evaluated #{connections.size} paths, found #{@next_hexside_bit} unique hexsides, and found valid routes "\
          "#{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} in: #{Time.now - now}"
      end

      static.each do |route|
        # recompute bitfields of passed-in routes since the bits may have changed across auto-router runs
        route.bitfield = bitfield_from_connection(route.connection_data, hexside_bits)
        train_routes[route.train] = [route] # force this train's route to be the passed-in one
      end

      train_routes.each do |train, routes|
        train_routes[train] = routes.sort_by(&:revenue).reverse.take(route_limit)
      end

      [train_routes, path_walk_timed_out]
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
              LOGGER.debug do
                "  ERROR: auto-router found unexpected number of path node edges #{node1.edges.size}. "\
                  'Route combos may be be incorrect'
              end
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

    %x{
      class Autorouter {
        constructor(router, trains_to_routes_map, update_callback) {
          this.router = router;
          this.trains_to_routes_map = trains_to_routes_map;
          this.update_callback = update_callback;
        }

        // Give an upper bound estimate for the revenue for the routes. Ideally, this is as tight as possible since it reduces
        // the number of calls to the real revenue function which is quite heavy. This returns -1 if the routes are invalid.
        estimate_revenue(routes_metadata) {
          if (routes_metadata.invalid_because_overlap) {
            return -1;
          }
          return routes_metadata.estimate_revenue;
        }


        // This is a heuristic to determine if we should continue exploring theroutes. If we have a route combo prefix that is
        // invalid and we know can't become true, we should return false here. Ideally we return false as often as possible since
        // this will prune the search space and make the autorouter faster.
        is_worth_adding_trains(routes, routes_metadata, current_train_data) {
          // If we hit an invalid overlap, we know we will always return -1 from estimate_revenue even if we add more trains, so
          // we can stop exploring this route combo prefix.
          if (routes_metadata.invalid_because_overlap) {
              return false;
          }

          // TODO: I wonder if it's always true that revenue is less than
          // or equal to the sum of the revenues of trains individually
          return (
            routes_metadata.estimate_revenue +
              current_train_data.max_possible_revenue_for_rest_of_trains >
              this.best_revenue_so_far
          );
        }

        // This is the helper function which does all the bookkeeping of metadata about the current route combo. It is likely
        // this will be extended with more fields if we add more hueristics
        add_train_to_routes_metadata(
          route,
          train_group,
          metadata,
        ) {
          let bitfield = [...metadata.bitfield];
          bitfield[train_group] = js_route_bitfield_merge(
              route.bitfield,
              bitfield[train_group],
          );
          return {
            estimate_revenue:
              metadata.estimate_revenue + route.estimate_revenue,
            bitfield,
            invalid_because_overlap:
              metadata.invalid_because_overlap ||
              js_route_bitfield_conflicts(
                route.bitfield,
                metadata.bitfield[train_group],
              ),
          };
        }

        // This is the base case metadata that should match the structure of add_train_to_routes_metadata
        get_empty_metadata(number_train_groups) {
          return {
            estimate_revenue: 0,
            bitfield: new Array(number_train_groups).fill(null).map(() => []),
            invalid_because_overlap: false,
          };
        }

        async autoroute() {
          this.start_of_all = this.start_of_execution_tick = performance.now();
          this.best_revenue_so_far = 0; // the best revenue we have found for a valid set of trains
          this.best_routes = []; // the best set of routes
          let trains_to_routes = Array.from(this.trains_to_routes_map).map(
            ([train, routes]) => [...routes, null], // add a null route to the end for the "no route for this train" case
          );

          if (trains_to_routes.length === 0) {
            this.router.running = false;
            this.update_callback([]);
            return;
          }

          for (let i = 0; i < trains_to_routes.length; ++i) {
            // the last route is the null route so skip it
            for (let j = 0; j < trains_to_routes[i].length - 1; ++j) {
              trains_to_routes[i][j].estimate_revenue = trains_to_routes[i][j].revenue;
            }
          }
          let train_data = null;
          let number_train_groups = 0;
          trains_to_routes.forEach((routes) => {
            let r = train_data
              ? train_data.max_possible_revenue_for_rest_of_trains
              : 0;
            r += routes[0].estimate_revenue;
            let train_group = 0;
            const game_group_rules = this.router.train_autoroute_group;
            if (game_group_rules == "each_train_separate") {
              train_group = number_train_groups;
              ++number_train_groups;
            } else if (Array.isArray(game_group_rules) && routes.length > 0) {
              const train_name = routes[0].$train().$name();
              train_group = game_group_rules.findIndex(group => group.includes(train_name)) + 1;
              number_train_groups = game_group_rules.length + 1;
            } else {
              number_train_groups = 1;
            }
            train_data = {
              routes,
              train_group,
              max_possible_revenue_for_rest_of_trains: r,
              next_train_data: train_data,
            };
          });
          this.find_best_combo([], this.get_empty_metadata(number_train_groups), train_data).then(() => {
            let best_routes = this.best_routes;
            // Fix up the revenue calculations since routes revenue can be
            // impacted by each other
            this.router.$real_revenue(best_routes)
            this.router.running = false
            Opal.LOGGER.$info("routing phase took " + (performance.now() - this.start_of_all) + "ms")
            this.update_callback(best_routes);
          }).catch((e) => {
            let best_routes = this.best_routes;
            this.router.flash("Auto route selection failed to complete (" + e + ")");
            Opal.LOGGER.$error("routing phase failed with: " + e);
            Opal.LOGGER.$error("routing exception backtrace:\n" + e.stack);
            this.router.running = false;
            this.router.$real_revenue(best_routes)
            this.update_callback(best_routes);
          });
        }

        // This is the heavy recursive function which searches all combinations of routes per train. The high level view is that
        // the function recursively picks a route per train and checks if the route combo is better than the best route combo.
        // route_combo -- An array of routes that represents the prefix of selected routes per train
        // selected_routes_metadata : a bag of information to make searching faster which represents all the important
        //      information about the current route combo.
        // current_train_data : a bunch of information about the current train we are selecting a route for. This is a recursive
        //      data structure where we have a layer per train (.next_train_data).
        async find_best_combo(
          route_combo,
          starting_combo_metadata,
          current_train_data,
        ) {
          for (let route of current_train_data.routes) {
            if (await this.check_if_we_should_break()) {
              return;
            }

            let current_routes_metadata = starting_combo_metadata;
            if (route) { // route is null for the "empty route"
              current_routes_metadata = this.add_train_to_routes_metadata(
                route,
                current_train_data.train_group,
                starting_combo_metadata,
              );
              route_combo.push(route);
            }

            // if we have selected a route for every train, let's evaluate the route combo
            if (current_train_data.next_train_data === null) {
              let estimate = this.estimate_revenue(current_routes_metadata);
              if (estimate > this.best_revenue_so_far) {
                let revenue = this.router.$real_revenue(route_combo);
                if (revenue > this.best_revenue_so_far) {
                  this.best_revenue_so_far = revenue;
                  this.best_routes = route_combo.map((r) => r.$clone());
                  this.render = true;
                }
              }
            // if we have more trains to pick routes for, check if it's worth exploring and if so, explore!
            } else if (this.is_worth_adding_trains(route_combo, current_routes_metadata, current_train_data.next_train_data)) {
              await this.find_best_combo(route_combo, current_routes_metadata, current_train_data.next_train_data);
            }

            if (route) { // "unselect" the route for this train
                console.assert(route_combo.pop() === route, "AutoRouter: popped wrong route");
            }
          }
        }

        // This is a helper function to check if we should break out of the autorouter loop and update the UI.
        async check_if_we_should_break() {
          if (performance.now() - this.start_of_execution_tick > 30) {
            if (this.render) {
                this.router.$real_revenue(this.best_routes)
                this.update_callback(this.best_routes)
                this.render = false;
            }
            if (performance.now() - this.start_of_all > this.router.route_timeout * 1000) {
                throw new Error('ROUTE_TIMEOUT');
            }
            await next_frame();
            if (!this.router.running) {
              return true;
            }
            this.start_of_execution_tick = performance.now();
            return false;
          }
        }
      }

      function js_route_bitfield_conflicts(a, b) {
        "use strict";
        let index = Math.min(a.length, b.length) - 1;
        while (index >= 0) {
          if ((a[index] & b[index]) != 0) return true;
          index -= 1;
        }
        return false;
      }

      function js_route_bitfield_merge(a, b) {
        "use strict";
        let max = Math.max(a.length, b.length);
        let result = [];
        for (let i = 0; i < max; ++i) {
          result.push((a[i] ?? 0) | (b[i] ?? 0));
        }
        return result;
      }

      function next_frame() {
        "use strict";
        return new Promise(resolve => requestAnimationFrame(resolve));
      }
    }
  end
end
