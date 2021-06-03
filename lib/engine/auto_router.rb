# frozen_string_literal: true

require_relative 'game_error'
require_relative 'route'

module Engine
  class AutoRouter
    def initialize(game)
      @game = game
    end

    def compute(corporation)
      connections = {}

      nodes = @game.graph.connected_nodes(corporation).keys.sort_by do |node|
        revenue = corporation
          .trains
          .map { |train| node.route_revenue(@game.phase, train) }
          .max
        [
          node.tokened_by?(corporation) ? 0 : 1,
          node.offboard? ? 0 : 1,
          -revenue,
        ]
      end

      now = Time.now

      nodes.each do |node|
        if Time.now - now > 10
          puts 'Giving up path search'
          break
        else
          puts "Path search: #{nodes.index(node)} / #{nodes.size}"
        end

        node.walk(corporation: corporation) do |_, vp|
          paths = vp.keys

          chains = []
          chain = []
          left = nil
          right = nil

          complete = lambda do
            chains << { nodes: [left, right], paths: chain }
            left, right = nil
            chain = []
          end

          assign = lambda do |node|
            if !left
              left = node
            elsif !right
              right = node
              complete.call
            end
          end

          paths.each do |path|
            chain << path
            a, b = path.nodes

            assign.call(a) if a
            assign.call(b) if b
          end

          next if chains.empty?

          id = chains.flat_map { |chain| chain[:paths] }.sort!
          next if connections[id]

          connections[id] = chains.map do |chain|
            { left: chain[:nodes][0], right: chain[:nodes][1], chain: chain }
          end
        end
      end

      puts "Found #{connections.size} paths in: #{Time.now - now}"

      connections = connections.values

      train_routes = Hash.new { |h, k| h[k] = [] }

      puts 'Pruning paths to legal routes'
      now = Time.now
      connections.each do |connection|
        corporation.trains.each do |train|
          route = Engine::Route.new(
            @game,
            @game.phase,
            train,
            connection_data: connection,
          )
          route.revenue
          train_routes[train] << route
        rescue GameError
        end
      end
      puts "Pruned paths to #{train_routes.map { |k, v| k.name + ':' + v.size.to_s}.join(', ')} in: #{Time.now - now}"

      limit = (1..train_routes.values.map(&:size).max).bsearch do |x|
        (x ** train_routes.size) >= 10000
      end

      train_routes.each do |train, routes|
        train_routes[train] = routes.sort_by(&:revenue).reverse.take(limit)
      end

      train_routes = train_routes.values.sort_by { |routes| -routes[0].paths.size }

      combos = [[]]

      puts "Finding route combos with depth #{limit}"
      counter = 0
      now = Time.now

      train_routes.each do |routes|
        combos = routes.flat_map do |route|
          combos.map do |combo|
            combo = combo + [route]
            route.routes = combo
            route.clear_cache!
            counter += 1
            puts "#{counter} / #{limit ** train_routes.size}" if counter % 1000 == 0
            route.revenue
            combo
          rescue GameError
          end
        end

        combos.compact!
      end

      puts "Found #{combos.size} possible routes in: #{Time.now - now}"


      combos.max_by do |routes|
        routes.each { |route| route.routes = routes}
        @game.routes_revenue(routes)
      end || []
    end
  end
end
