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

        # TODO: unwind and inline node/walk and path.walk

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
      first_route_limit = opts[:first_route_limit] || 100   # first (largest) train's route limit
      route_limit = opts[:route_limit] || 1_000             # other trains' route limit
      use_js_algorithm = opts[:use_js_algorithm] || false

      connections = {}
      trains = @game.route_trains(corporation)

      nodes = @game.graph.connected_nodes(corporation).keys.sort_by do |node|
        revenue = trains#@game.route_trains(corporation)
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

      train_routes = Hash.new { |h, k| h[k] = [] }    # map of train to route list
      path_abort = Hash.new { |h, k| h[k] = false }   # each train has opportunity to abort a branch of the path walk tree
      route_counter = Hash.new { |h, k| h[k] = 0 }

      trains.each do |train|
        path_abort[train] = false 
        route_counter[train] = 0
      end

      hexside_bits = Hash.new { |h, k| h[k] = 0 }     # map of hexside_id to bit number
      #route_bitfields = Hash.new { |h, k| h[k] = [] } # map of train to bitfield

      # table of bit 0-31 to bitmask
      bit_to_bitmask = []
      mask = 1
      i = 0
      while (i < 32) do
        bit_to_bitmask[i] = mask;
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

        #longest_train = 6 # TEMP super temp!

        walk_counter = 0 #TEMP
        counter = 0 #TEMP
        abort_count = 0 #TEMP
        skipped_mirror_routes = 0
        route_counter.each { |train,_| route_counter[train] = 0 }
        #bitfield = []

        node.walk(corporation: corporation, skip_paths: skip_paths) do |_, vp|
          paths = vp.keys

          abort = nil
          walk_counter += 1 #TEMP

          chains = []
          chain = []
          left = nil
          right = nil
          last_left = nil
          last_right = nil
          #bitfield = []

          complete = lambda do
            # assemble connection's bitfield one hexside at a time
#if (left.hex.coordinates == "C18") && (right.hex.coordinates == "C20")
#  puts " -- found C18-C20"
#end
            #TODO: this misses some hex connections for some reason
            # if (left != right) && (left.hex != right.hex) # not sure why left == right is possible, or in two ways!
            #   setBit(bitfield, bitFromHexes(left, right, hexside_bits), bit_to_bitmask)
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

          counter += 1 #TEMP

          # each train has opportunity to vote to abort a branch of this node's path-walk tree
          path_abort.each { |train,_| path_abort[train] = false }

          #build a test route for each train, use route.revenue to check for errors, keep the good ones
          trains.each do |train|
            if (! path_abort[train])
              # TODO: working to remove this (move up into prior loop so don't walk loop again)
              bitfield = bitfieldFromConnection(connection, hexside_bits, bit_to_bitmask)

              # exclude this route if a duplicate or mirror is already present
              # NOTE: the mirror check is very cpu intensive currently, and there aren't that many mirror routes found,
              #  so it's faster to just add mirror routes to the collections and run them through the combo generator
              if (false)  #tableContainsBitfield(route_bitfields[train], bitfield))
                skipped_mirror_routes += 1
              else
                route = Engine::Route.new(
                  @game,
                  @game.phase,
                  train,
                  connection_data: connection,
                  bitfield: bitfield,
                )
                #route_bitfields[train] << bitfield

                #Looked into route.distance as a quicker way to check at least too-long route if that's the majority failure case
                #(would still keep route.revenue to handle other cases)
                #Turns out it does slightly improve speed, but I worry about unintended side effects, comparing two numbers here
                #may not be enough precision on unique train types like 3+3 or even diesel
                # if (route.distance > longest_train)
                #   #puts "route.distance #{route.distance} > longest_train #{longest_train}"
                #   abort_count += 1
                #   abort = :abort  # this path is dead for all trains, don't walk it further
                # else
                #  if (route.distance <= train.distance)
                #    route.revenue   # raises various errors if bad route
                #    train_routes[train] << route
                #    route_counter[train] += 1 #TEMP
                #  end
                # end

                route.revenue   # raises various errors if bad route
                train_routes[train] << route
                route_counter[train] += 1 #TEMP
              end # if ! tableContainsBitfield
            end # if (! path_abort[train])

          # These all result in the route not being added to train_routes[train],
          # but the nature of the error determines how to continue or terminate processing of the connection path
          rescue RouteTooLong => msg
            # ignore for this train, and abort walking this path if ignored for all trains
            #puts msg
            path_abort[train] = true  # path is dead for this train
            if (path_abort.values.all?)
              abort_count += 1
              abort = :abort  # this path is dead for all trains, don't walk it further
            end
          rescue NoToken => msg
            # keep extending this connection set
            #puts msg
          rescue RouteTooShort => msg
            # keep extending this connection set
            #puts msg
          rescue ReusesCity => msg
            #puts msg
            abort = :abort  # this path is dead, don't walk it further
          rescue RouteBlocked => msg
            #puts msg
            abort = :abort  # this path is dead, don't walk it further
          rescue GameError => msg
            # an unhandled route error that probably needs handling
            puts msg
          end # trains.each do
          abort
        end # node.walk
        puts " node.walk iterated #{walk_counter} times, built #{counter} connections, skipped #{skipped_mirror_routes} mirror routes, added routes #{route_counter.map { |k, v| k.name + ':' + v.to_s }.join(', ')}, and aborted #{abort_count} path branches" #TEMP
      end # nodes.each

      puts "Evaluated #{connections.size} paths, found #{hexside_bits.size/2} unique hexsides, and found valid routes #{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} in: #{Time.now - now}"

      static.each { |route| train_routes[route.train] = [route] }

      first = true
      train_routes.each do |train, routes|
        limit = first ? first_route_limit : route_limit
        train_routes[train] = routes.sort_by(&:revenue).reverse.take(limit)
        first = false
      end

      #  Code Review note
      #sorted_routes = train_routes.values.sort_by(&:size)
      #  Sorting by route array size has intermittent problems if the longer train has fewer routes, like if I limit the first
      #  train's routes.  A suboptimal combo revenue is found in some test scenarios.
      #  Regardless of whether that first-train constraint is kept or discarded, sorting by array size here could be a latent bug;
      #  perhaps if all train's routes are limited to route_limit, the sort order of ties may be unprdictable.
      #  I'd rather sort by train size, which I assume was the original intent.
      sorted_routes = train_routes.map {|train, routes| routes}

      train_routes.each do |train, routes|
        #puts "  #{train.name}-train"
        #puts "    best route: $#{routes[0].revenue}"
        #puts "    worst route: $#{routes[routes.size-1].revenue}"
      end

      limit = sorted_routes.map(&:size).reduce(&:*)
      puts "Finding route combos of best #{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} routes with depth #{limit}"
      # counter = 0
      # max_revenue = 0
      # conflicts = 0
      # now = Time.now

      #IN PROGRESS: try a pure js combo algorithm
      if use_js_algorithm
        possibilities = js_evaluateCombos(sorted_routes, route_timeout)
      else
        possibilities = evaluateCombos(sorted_routes, route_timeout)
      end

# if (RUBY_ENGINE == 'opal') && use_js_algorithm
#       # The embedded js (in Opal) algorithm
#       `
#       console.log("** Using javascript combo-generator **")
      
#       `
# else # ! Opal
#       # The Ruby algorithm
#       sorted_routes.each do |routes|
#         combos = routes.flat_map do |route|
#           combos.map do |combo|
#             counter += 1
#             if (counter % 50000).zero?
#               puts "#{counter} / #{limit}"
#               raise if Time.now - now > route_timeout
#             end
#             if (routeBitfieldConflicts(combo, route))
#               conflicts += 1
#             else
#               combo += [route]
#               route.routes = combo
#               route.clear_cache!(only_routes: true)

#               possibilities_count += 1
#               #route.revenue     # throws GameError if routes in the combo conflict
#               route.auto_router_revenue #simple revenue calc without route validity checks
#               combo_revenue = @game.routes_revenue(combo)

#               # accumulate best-value routes, or start over if found a bigger best
#               if (combo_revenue >= max_revenue)
#                 if (combo_revenue > max_revenue)
#                   possibilities.clear
#                   max_revenue = combo_revenue
#                   #puts "  new max_revenue found $#{max_revenue}"
#                 end
#                 possibilities << combo
#               end
#               combo
#             end
#           rescue GameError => msg # rubocop:disable Lint/SuppressedException
#             puts " route.auto_router_revenue rejected a conflicting route - SHOULD NEVER HAPPEN - #{msg}"
#           end
#         end

#         combos.compact!
#       rescue RuntimeError
#         puts 'Route timeout reached'
#         break
#       end # sorted_combos.each
# end # RUBY_ENGINE

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
      rescue GameError => msg  # rubocop:disable Lint/SuppressedException
        # don't include a combo with errored route in the result set
        puts " Sanity check error, likely an auto_router bug: #{msg}"
        puts "   route: #{bad_route.connection_hexes.map { |hex| hex }.join('-')}"
        #puts "   cities: #{bad_route.visited_stops.map { |city| city.hex.coordinates }.join('-')}"
        puts "   other combo routes:"
        routes.each do |route|
          puts "     #{route.connection_hexes.map { |hex| hex }.join('-')}" if route != bad_route
        end
        #puts "   route: #{bad_route.connection_hexes.map.join('-')}"
      end || []

      max_routes.each { |route| route.routes = max_routes }
    end # test_compute()

    #
    # The Ruby algorithm
    #
    def evaluateCombos (sorted_routes, route_timeout)
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
            if (counter % 50000).zero?
              puts "#{counter} / #{limit}"
              raise if Time.now - now > route_timeout
            end
            if (routeBitfieldConflicts(combo, route))
              conflicts += 1
            else
              combo += [route]
              route.routes = combo
              route.clear_cache!(only_routes: true)

              possibilities_count += 1
              #route.revenue     # throws GameError if routes in the combo conflict
              route.auto_router_revenue #simple revenue calc without route validity checks
              combo_revenue = @game.routes_revenue(combo)

              # accumulate best-value routes, or start over if found a bigger best
              if (combo_revenue >= max_revenue)
                if (combo_revenue > max_revenue)
                  possibilities.clear
                  max_revenue = combo_revenue
                  #puts "  new max_revenue found $#{max_revenue}"
                end
                possibilities << combo
              end
              combo
            end
          rescue GameError => msg # rubocop:disable Lint/SuppressedException
            puts " route.auto_router_revenue rejected a conflicting route - SHOULD NEVER HAPPEN - #{msg}"
          end # combos.map
        end # route.flat_map

        combos.compact!
      rescue RuntimeError
        puts 'Route timeout reached'
        break
      end # sorted_combos.each

      puts "Found #{possibilities_count} possible combos (#{possibilities.size} best) and rejected #{conflicts} conflicting combos in: #{Time.now - now}"
      possibilities
    end # def evaluateCombos

    #inputs:
    #   connection is a route's connection_data
    #   hexside_bits is a map of hexside_id to bit number
    #   bit_to_bitmask is a helper table of bit 0-31 to integer bitmask (essentially 1 << bit)
    #returns:
    #   the bitfield (array of ints) representing all hexsides in the connection path
    #updates:
    #   new hexsides are added to hexside_bits
    def bitfieldFromConnection(connection, hexside_bits, bit_to_bitmask)
      bitfield = [0]
      connection.each do |conn|
        paths = conn[:chain][:paths]
        index = 1
        stop = paths.size
        node2 = paths[0]
        while index < stop do
          # micro-optimized ruby gives much faster opal code
          node1 = node2
          node2 = paths[index]
          #TODO: use the two nodes as dual keys, hexside = [n1,n2], rather than concatenating strings
          #hexside = conn[:chain][:paths][index].hex.coordinates + '-' + conn[:chain][:paths][index+1].hex.coordinates
          #hexside = [node1, node2]
          #hexside = node1.hex.coordinates + '-' + node2.hex.coordinates
          #hexside = [ node1.hex.coordinates , node2.hex.coordinates ]
          hexside = node1.hex.coordinates + node2.hex.coordinates
          if (hexside_bits.include?(hexside))
            setBit(bitfield, hexside_bits[hexside], bit_to_bitmask)
          else
            # try the reverse direction (same hexside)
            #reverse = conn[:chain][:paths][index+1].hex.coordinates + '-' + conn[:chain][:paths][index].hex.coordinates
            #reverse = [node2, node1]
            #reverse = node2.hex.coordinates + '-' + node1.hex.coordinates
            #reverse = [ node2.hex.coordinates , node1.hex.coordinates ]
            reverse = node2.hex.coordinates + node1.hex.coordinates
            if (hexside_bits.include?(reverse))
              setBit(bitfield, hexside_bits[reverse], bit_to_bitmask)
            else
              bit = hexside_bits.size / 2 # there are two entries for each bit, forward and reverse
              #puts " bitfieldFromConnection adding bit #{newbit} for #{hexside} and #{reverse}"
              hexside_bits[hexside] = bit
              hexside_bits[reverse] = bit
              setBit(bitfield, bit, bit_to_bitmask)
            end
          end
          index += 1
        end
      end
      bitfield
    end

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
    def setBit(bitfield, bit, bit_to_bitmask)
      entry = (bit / 32).to_i     # which array entry do we need
      #mask = 1 << bit.modulo(32)  # which bit in that int to set
      #mask = bit_to_bitmask[bit.modulo(32)]  # which bit in that int to set
      mask = bit_to_bitmask[bit & 31]  # which bit in that int to set
      addCount = entry + 1 - bitfield.size 
      while addCount > 0 do
        bitfield << 0         # add a new integer to the array
        addCount -= 1
      end
      bitfield[entry] |= mask
    end

    # does testroute's bitfield conflict with any other routes in the combo?
    def routeBitfieldConflicts(combo, testroute)
      combo.each do |route|
        # each route has 1 or more ints in bitfield array
        # only test up to the shorter size, since bits beyond that obviously don't conflict
        # index = [ route.bitfield.size, testroute.bitfield.size ].min - 1
        # while index >= 0 do
        #   if ((route.bitfield[index] & testroute.bitfield[index]) != 0)
        #     return true
        #   end
        #   index -= 1
        # end

        # ruby makes array comparison easier, hopefully with faster opal result
        index = 0
        while index < testroute.bitfield.size do
          return true if (route.bitfield[index] & testroute.bitfield[index]) != 0
          index += 1
        end
      end
      false
    end

    # does test bitfield equal any other bitfields in the table?
    def tableContainsBitfield(table, testbitfield)
      #slower
      #table.map{|bitfield| bitfield == testbitfield}.reduce(:|)

      #also slow
      table.any?{|bitfield| bitfield == testbitfield}

      # faster but still slow
      # table.each do |bitfield|
      #   if (bitfield == testbitfield)
      #     return true
      #   end
      # end
      # false
    end

    #
    # The js-in-Opal algorithm
    #
    def js_evaluateCombos (rb_sorted_routes, route_timeout)
      if RUBY_ENGINE == 'opal'
        rb_possibilities = []
        possibilities_count = 0
        conflicts = 0
        limit = rb_sorted_routes.map(&:size).reduce(&:*)
        now = Time.now

        puts "** Using javascript combo-generator **"

        # TODO: restructure sorted_routes for js
        `
        possibilities = []
        combos = [];
        counter = 0;
        max_revenue = 0;

        //
        // marshal Opal objects to js for faster/easier access
        //
        js_sorted_routes = [];
        //for (rb_routes of rb_sorted_routes)
        Opal.send(rb_sorted_routes, 'each', [], function(rb_routes)
          {
            js_routes = [];
            //for (rb_route of rb_routes)
            Opal.send(rb_routes, 'each', [], function(rb_route)
            {
              //js_routes.push( { route: rb_route, bitfield: rb_route.$fetch('bitfield'), revenue: rb_route.$fetch('revenue') } );
              js_routes.push( { route: rb_route, bitfield: rb_route.bitfield, revenue: rb_route.revenue } );
            });
            js_sorted_routes.push(js_routes);
          });

        //
        // init combos with first train's routes
        //
        for (route of js_sorted_routes[0])
        {
          counter += 1;
          combo = { revenue: route.revenue, routes: [route] };
          combos.push(combo);
          possibilities_count += 1;
          if (route.revenue > max_revenue)
            max_revenue = route.revenue;
        }

        //
        // generate combos with remaining trains' routes
        //
        r = 1;
        while (r < js_sorted_routes.length)
        {
          new_combos = [];
          for (route of js_sorted_routes[r])
          {
            for (combo of combos)
            {
              counter += 1;
              if ((counter % 1_000_000) == 0)
                console.log(counter + " / " + limit);

              if (js_routeBitfieldConflicts(combo, route))
                conflicts += 1;
              else
              {
                possibilities_count += 1;

                // copy the combo, add the route
                newcombo = { revenue: combo.revenue, routes: [...combo.routes] };
                newcombo.routes.push(route);
                newcombo.revenue += route.revenue;
                new_combos.push(newcombo);

                // accumulate best-value routes, or start over if found a bigger best
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
              r += 1;
            }
          }
          for (combo of new_combos)
            combos.push(combo);
        }
        //console.log("final counter: " + counter + ", limit: " + limit);
        //console.log("Found " + possibilities_count + " possible combos (" + possibilities.length + " best) and rejected " + conflicts + " conflicting combos");

        //
        // marshall best combos back to Opal
        //
        for (combo of possibilities)
        {
          rb_routes = []
          for (route of combo.routes)
          {
            rb_routes['$<<'](route.route);
          }
          rb_possibilities['$<<'](rb_routes);
        }

/*
        sorted_routes.each do |routes|
          combos = routes.flat_map do |route|
            combos.map do |combo|
              counter += 1
              if (counter % 500000).zero?
                puts "#{counter} / #{limit}"
                raise if Time.now - now > route_timeout
              end
              if (routeBitfieldConflicts(combo, route))
                conflicts += 1
              else
                combo += [route]
                route.routes = combo
                route.clear_cache!(only_routes: true)

                possibilities_count += 1
                #route.revenue     # throws GameError if routes in the combo conflict
                route.auto_router_revenue #simple revenue calc without route validity checks
                combo_revenue = @game.routes_revenue(combo)

                # accumulate best-value routes, or start over if found a bigger best
                if (combo_revenue >= max_revenue)
                  if (combo_revenue > max_revenue)
                    possibilities.clear
                    max_revenue = combo_revenue
                    #puts "  new max_revenue found $#{max_revenue}"
                  end
                  possibilities << combo
                end
                combo
              end
            rescue GameError => msg # rubocop:disable Lint/SuppressedException
              puts " route.auto_router_revenue rejected a conflicting route - SHOULD NEVER HAPPEN - #{msg}"
            end # combos.map
          end # route.flat_map

          combos.compact!
        rescue RuntimeError
          puts 'Route timeout reached'
          break
        end # sorted_combos.each
*/
        `
        max_routes = rb_possibilities.max_by do |routes|
          routes.each { |route| route.routes = routes }
          @game.routes_revenue(routes)
        end || []
  
      else # not Opal
        puts "** javascript combo-generator requested but not in Opal environment - no combos computed* *"
      end

      puts "Found #{possibilities_count} possible combos (#{rb_possibilities.size} best) and rejected #{conflicts} conflicting combos in: #{Time.now - now}"
      rb_possibilities
    end # def js_evaluate_combos

    `
    function js_routeBitfieldConflicts(combo, testroute)
    {
      for (cr of combo.routes)
      {
        // each route has 1 or more ints in bitfield array
        // only test up to the shorter size, since bits beyond that obviously don't conflict
        index = Math.min(cr.bitfield.length, testroute.bitfield.length) - 1;
        while (index >= 0)
        {
          if ((cr.bitfield[index] & testroute.bitfield[index]) != 0)
          {
            return true;
          }
          index -= 1;
        }
      }
      return false;
    }
    `

  end
end
