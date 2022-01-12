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

      puts "Found #{possibilities.size} possible routes in: #{Time.now - now}"

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
      first_route_limit = opts[:first_route_limit] || 100   # first (largest train's route limit
      route_limit = opts[:route_limit] || 1_000             # other trains' route limit

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
      route_bitfields = Hash.new { |h, k| h[k] = [] } # map of train to bitfield table

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

          counter += 1 #TEMP

          # each train has opportunity to vote to abort a branch of this node's path-walk tree
          path_abort.each { |train,_| path_abort[train] = false }

          #build a test route for each train, use route.revenue to check for errors, keep the good ones
          trains.each do |train|
            if (! path_abort[train])
              bitfield = bitfieldFromConnection(connection, hexside_bits)

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

      sorted_routes = train_routes.values.sort_by(&:size)

      combos = [[]]
      possibilities = []
      possibilities_count = 0

      limit = sorted_routes.map(&:size).reduce(&:*)
      puts "Finding route combos of best #{train_routes.map { |k, v| k.name + ':' + v.size.to_s }.join(', ')} routes with depth #{limit}"
      counter = 0
      max_revenue = 0
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
                end
                possibilities << combo
              end
              combo
            end
          rescue GameError => msg # rubocop:disable Lint/SuppressedException
            puts " route.auto_router_revenue rejected a conflicting route - SHOULD NEVER HAPPEN - #{msg}"
          end
        end

        combos.compact!
      rescue RuntimeError
        puts 'Route timeout reached'
        break
      end # sorted_combos.each

      # final sanity check on best combos: recompute each route.revenue in case it needs to reject a combo
      max_routes = possibilities.max_by do |routes|
        routes.each do |route|
          route.clear_cache!(only_routes: true)
          route.routes = routes
          route.revenue
        end
        @game.routes_revenue(routes)
      rescue GameError => msg  # rubocop:disable Lint/SuppressedException
        # don't include a combo with errored route in the result set
        puts " route.revenue rejecting combo for route error - likely an auto_router bug - #{msg}"
      end || []

      puts "Found #{possibilities_count} possible combos (#{max_routes.size} best) and rejected #{conflicts} conflicting combos in: #{Time.now - now}"

      max_routes.each { |route| route.routes = max_routes }
    end # test_compute()

    #inputs:
    #   connection is a route's connection_data
    #   hexside_bits is a map of hexside_id to bit number
    #returns:
    #   the bitfield (array of ints) representing all hexsides in the connection path
    #updates:
    #   new hexsides are added to hexside_bits
    def bitfieldFromConnection(connection, hexside_bits)
      bitfield = [0]
      connection.each do |conn|
        index = 0
        pathcount = conn[:chain][:paths].size
        while index < pathcount-1 do
          hexside = conn[:chain][:paths][index].hex.coordinates + '-' + conn[:chain][:paths][index+1].hex.coordinates
          if (hexside_bits.include?(hexside))
            setBit(bitfield, hexside_bits[hexside])
          else
            # try the reverse direction (same hexside)
            reverse = conn[:chain][:paths][index+1].hex.coordinates + '-' + conn[:chain][:paths][index].hex.coordinates
            if (hexside_bits.include?(reverse))
              setBit(bitfield, hexside_bits[reverse])
            else
              newbit = hexside_bits.size / 2 # there are two entries for each bit, forward and reverse
              hexside_bits[hexside] = newbit
              hexside_bits[reverse] = newbit
              setBit(bitfield, newbit)
            end
          end
          index += 1
        end
      end
      bitfield
    end

    # bitfield is an array of integers, can be expanded by this call if necessary
    # bit is a bit number, 0 is lowest bit, 32 will jump to the next int in the array, and so on
    def setBit(bitfield, bit)
      entry = (bit / 32).to_i   # which array entry do we need
      shift = bit.modulo(32)    # which bit in that int to set
      addCount = entry + 1 - bitfield.size 
      while addCount > 0 do
        bitfield << 0         # add a new integer to the array
        addCount -= 1
      end
      bitfield[entry] |= 1 << shift
    end

    # does testroute's bitfield conflict with any other routes in the combo?
    def routeBitfieldConflicts(combo, testroute)
      combo.each do |route|
        # each route has 1 or more ints in bitfield array
        # only test up to the shorter size, since bits beyond that obviously don't conflict
        index = [ route.bitfield.size, testroute.bitfield.size ].min - 1
        while index >= 0 do
          if ((route.bitfield[index] & testroute.bitfield[index]) != 0)
            return true
          end
          index -= 1
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

  end
end
