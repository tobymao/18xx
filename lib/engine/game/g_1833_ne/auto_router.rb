# frozen_string_literal: true

require_relative '../../auto_router'

module Engine
  module Game
    module G1833NE
      class AutoRouter < Engine::AutoRouter
        def path(trains, corporation, **opts)
          traced = (opts[:routes] || []).map(&:train)
          super(trains.map { |train| traced.include?(train) ? train : extension_train(train) }, corporation, **opts)
        end

        def route(train_routes, callback)
          super(train_routes, ->(routes) { callback.call(with_extensions(routes)) })
        end

        def extension_train(train)
          @extension_trains ||= {}
          extension = (@extension_trains[train] ||= Engine::Train.new(
            name: train.name,
            distance: train.distance.reject { |h| h['extension'] },
            price: train.price,
            index: train.index,
          ))
          extension.owner = train.owner
          extension
        end

        def extension_train?(train)
          @extension_trains&.value?(train)
        end

        def estimate_revenue(route)
          @estimates ||= {}
          @estimates[route] ||= route.revenue + extension_value([route])
        end

        def real_revenue(routes)
          revenue = super
          revenue.negative? ? revenue : revenue + extension_value(routes)
        end

        def extension_value(routes)
          interconnection_claims(routes).values.sum { |claim| claim[:value] }
        end

        def with_extensions(routes)
          claims = interconnection_claims(routes)
          final = routes.map do |route|
            next route unless extension_train?(route.train)

            stops = @game.running_stops(route)
            chains = route.connection_data.select { |c| c[:left] && c[:right] }.map { |c| c[:chain] }
            if (claim = claims[route]) && stops.last != claim[:from]
              stops = stops.reverse
              chains = chains.reverse
            end
            connections = stops.each_cons(2).zip(chains).map { |(left, right), chain| { left: left, right: right, chain: chain } }
            connections += claim[:connections] if claim
            Engine::Route.new(@game, @game.phase, @extension_trains.key(route.train), connection_data: connections)
          end
          final.each { |route| route.routes = final }
          final
        end

        def interconnection_claims(routes)
          routes = routes.compact
          candidates = routes.select { |route| extension_train?(route.train) }
                             .to_h { |route| [route, interconnection_candidates(route)] }
                             .reject { |_route, list| list.empty? }
          return {} if candidates.empty?

          used = {}
          routes.each do |route|
            route.paths.each { |path| track_keys(path).each { |key| used[key] = true } }
          end

          best = { value: 0, claims: {} }

          candidates.keys.permutation.each do |order|
            assign_interconnections(order, candidates, used, {}, 0, best)
          end
          best[:claims]
        end

        def assign_interconnections(order, candidates, used, claims, value, best)
          if order.empty?
            if value > best[:value]
              best[:value] = value
              best[:claims] = claims.dup
            end
            return
          end

          route, *rest = order
          possible = rest.sum { |other| candidates[other].first[:value] }
          searched = {}

          candidates[route].each do |candidate|
            break if value + candidate[:value] + possible <= best[:value]

            # the same search for a smaller bonus cannot do better
            key = [candidate[:from], candidate[:destination]]
            next if searched[key]

            searched[key] = true
            next unless (extension = find_extension(candidate, used))

            extension[:keys].each { |track| used[track] = true }
            claims[route] = { value: candidate[:value], from: candidate[:from], connections: extension[:connections] }
            assign_interconnections(rest, candidates, used, claims, value + candidate[:value], best)
            claims.delete(route)
            extension[:keys].each { |track| used.delete(track) }
          end

          return if value + possible <= best[:value]

          assign_interconnections(rest, candidates, used, claims, value, best)
        end

        def interconnection_candidates(route)
          ordered = @game.running_stops(route)
          return [] if ordered.size < 2

          candidates = [ordered, ordered.reverse].flat_map do |stops|
            exit_stop = stops.last
            next [] if exit_stop.offboard?

            stops[0..-2].each_with_index.flat_map do |origin, index|
              @game.class::INTERCONNECTION_BONUSES.filter_map do |bonus|
                next unless @game.stop_in_group?(origin, bonus[:origin])
                next if stops[index..-1].any? { |stop| @game.stop_in_group?(stop, bonus[:destination]) }

                value = @game.bonus_value(bonus, route)
                value += revenue_paying(route, origin) - route.revenue if value.positive?
                next unless value.positive?

                { value: value, from: exit_stop, destination: bonus[:destination], blocked: ordered }
              end
            end
          end
          candidates.sort_by { |candidate| -candidate[:value] }
        end

        def find_extension(candidate, used)
          from = candidate[:from]
          came_from = {}
          queue = []
          from.paths.each do |path|
            next if path.ignore? || !track_free?(path, used)

            state = [path, path.a == from ? path.b : path.a]
            came_from[state] = :start
            queue << state
          end

          until queue.empty?
            state = queue.shift
            path, out = state

            if !out.edge? && !out.junction? && @game.stop_in_group?(out, candidate[:destination])
              extension = extension_from(from, state, came_from)
              return extension if extension

              next
            end

            extension_steps(path, out, candidate[:blocked]).each do |step|
              next if came_from[step] || step[0].ignore? || !track_free?(step[0], used)

              came_from[step] = state
              queue << step
            end
          end

          nil
        end

        def extension_steps(path, out, blocked)
          if out.edge?
            hex = path.hex
            return [] unless (neighbor = hex.neighbors[out.num])

            edge = hex.invert(out.num)
            neighbor.paths[edge].filter_map do |other|
              next unless path.lane_match?(path.exit_lanes[out.num], other.exit_lanes[edge])
              next unless path.tracks_match?(other, dual_ok: true)

              [other, other.a.edge? && other.a.num == edge ? other.b : other.a]
            end
          elsif !out.junction? && (out.offboard? || path.terminal? || blocked.include?(out))
            []
          else
            out.paths.filter_map { |other| [other, other.a == out ? other.b : other.a] unless other == path }
          end
        end

        def extension_from(from, state, came_from)
          states = []
          while state != :start
            states.unshift(state)
            state = came_from[state]
          end

          keys = states.flat_map { |path, _out| track_keys(path) }
          stops = states.map { |_path, out| out }.reject { |out| out.edge? || out.junction? }
          return if keys.uniq.size != keys.size || stops.uniq.size != stops.size

          connections = []
          left = from
          paths = []
          states.each do |path, out|
            paths << path
            next if out.edge? || out.junction?

            connections << { left: left, right: out, chain: { nodes: [left, out], paths: paths, hexes: paths.map(&:hex) } }
            left = out
            paths = []
          end
          { connections: connections, keys: keys }
        end

        def track_free?(path, used)
          track_keys(path).none? { |key| used[key] }
        end

        def track_keys(path)
          a = path.a
          b = path.b
          hex = path.hex
          keys = []
          keys << [hex, a.num, path.lanes[0][1]] if a.edge?
          keys << [hex, b.num, path.lanes[1][1]] if b.edge?
          if b.edge? && a.town? && (edge = a.tile.preferred_city_town_edges[a]) && edge != b.num
            keys << [hex, a, path.lanes[0][1]]
          end
          if a.edge? && b.town? && (edge = b.tile.preferred_city_town_edges[b]) && edge != a.num
            keys << [hex, b, path.lanes[1][1]]
          end
          keys << [hex, path] if path.nodes.size > 1
          keys
        end
      end
    end
  end
end
