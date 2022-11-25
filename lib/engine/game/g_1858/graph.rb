# frozen_string_literal: true

require_relative '../../graph'

module Engine
  module Game
    module G1858
      class Graph < Engine::Graph
        # TODO: this method has been cut'n'pasted from Engine::Graph, with a
        # few modifications. The base class's compute method needs to be
        # refactored with methods extracted which can be overridden in this
        # class, without so much code duplicated.
        def compute(corporation, routes_only: false)
          hexes = Hash.new { |h, k| h[k] = {} }
          nodes = {}
          paths = {}

          @game.hexes.each do |hex|
            hex.tile.cities.each do |city|
              next unless @game.city_tokened_by?(city, corporation)
              next if @check_tokens && @game.skip_token?(self, corporation, city)

              hex.neighbors.each { |e, _| hexes[hex][e] = true }
              nodes[city] = true
            end
          end

          if @home_as_token
            home_hexes = Array(corporation.coordinates).map { |h| @game.hex_by_id(h) }
            cities = Array(corporation.city)
            home_hexes.zip(cities).each do |hex, city_idx|
              hex.neighbors.each { |e, _| hexes[hex][e] = true }
              if city_idx
                nodes[hex.tile.cities[city_idx]] = true
              elsif hex.tile.city_towns.any?
                hex.tile.city_towns.each { |ct| nodes[ct] = true }
              else
                # Plain track in a home hex (or no tile or track). Create a
                # node for each track path to allow routes to be traced out
                # from this hex.
                hex.tile.paths.each { |path| nodes[G1858::Part::PathNode.new(path)] = true }
              end
            end
          end

          tokens = nodes.dup

          @game.abilities(corporation, :token) do |ability, c|
            next unless c == corporation # token ability must be activated
            next unless ability.teleport_price

            ability.hexes.each do |hex_id|
              @game.hex_by_id(hex_id).tile.cities.each do |node|
                nodes[node] = true
                yield node if block_given?
              end
            end
          end

          @game.abilities(corporation, :teleport) do |ability, owner|
            next unless owner == corporation # teleport ability must be activated

            ability.hexes.each do |hex_id|
              hex = @game.hex_by_id(hex_id)
              hex.neighbors.each { |e, _| hexes[hex][e] = true }
              hex.tile.cities.each do |node|
                nodes[node] = true
                yield node if ability.used? && block_given?
              end
            end
          end

          routes = @routes[corporation] || {}
          walk_corporation = @no_blocking ? nil : corporation
          skip_paths = @game.graph_skip_paths(corporation)

          tokens.keys.each do |node|
            return nil if routes[:route_train_purchase] && routes_only

            visited = tokens.reject { |token, _| token == node }
            local_nodes = {}

            node.walk(visited: visited, corporation: walk_corporation, skip_track: @skip_track,
                      skip_paths: skip_paths, converging_path: false) do |path, _, _|
              next if paths[path]

              paths[path] = true

              path.nodes.each do |p_node|
                nodes[p_node] = true
                local_nodes[p_node] = true
                yield p_node if block_given?
              end

              hex = path.hex

              path.exits.each do |edge|
                hexes[hex][edge] = true
                hexes[hex.neighbors[edge]][hex.invert(edge)] = true
              end
            end

            next if routes[:route_train_purchase]

            mandatory_nodes = 0
            optional_nodes = 0
            local_nodes.each do |p_node, _|
              case p_node.route
              when :mandatory
                mandatory_nodes += 1
              when :optional
                optional_nodes += 1
              end
            end

            if mandatory_nodes > 1
              routes[:route_available] = true
              routes[:route_train_purchase] = true
              @routes[corporation] = routes
            elsif mandatory_nodes == 1 && optional_nodes.positive?
              routes[:route_available] = true
            end
          end

          hexes.default = nil
          hexes.transform_values!(&:keys)

          # connected_hexes - hexes in which this corporation can lay track
          # connected_nodes - hexes in which this corporation can token
          # reachable_hexes - hexes in which this corporation can run

          @routes[corporation] = routes
          @connected_hexes[corporation] = hexes
          @connected_nodes[corporation] = nodes
          @connected_paths[corporation] = paths
          @reachable_hexes[corporation] = paths.to_h { |path, _| [path.hex, true] }
        end
      end
    end
  end
end
