# frozen_string_literal: true

require_relative 'game_error'
require_relative 'route'

module Engine
  class AutoRouter
    def initialize(game, flash)
      @game = game
      @flash = flash
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
        @flash.call('Auto route selection failed to complete (timeout)')
        break
      end

      puts "Found #{possibilities.size} possible routes in: #{Time.now - now}"

      max_routes = possibilities.max_by do |routes|
        routes.each { |route| route.routes = routes }
        @game.routes_revenue(routes)
      end || []

      max_routes.each { |route| route.routes = max_routes }
    end
  end
end
