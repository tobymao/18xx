# frozen_string_literal: true

require_relative '../base'
require_relative 'tracker'

module Engine
  module Step
    module G1860
      class Track < Base
        include Tracker
        ACTIONS = %w[lay_tile pass].freeze

        def actions(entity)
          return [] if entity.company? || !can_lay_tile?(entity)

          entity == current_entity ? ACTIONS : []
        end

        def description
          'Lay Track'
        end

        def pass_description
          @acted ? 'Done (Track)' : 'Skip (Track)'
        end

        def process_lay_tile(action)
          lay_tile_action(action)
          pass! unless can_lay_tile?(action.entity)
        end

        def reachable_node?(entity, node)
          max_distance = @game.biggest_train(entity).distance
          return false if max_distance.zero?

          node_distances = @game.node_distances(entity)
          return false unless node_distances[node]

          if node.city?
            node_distances[node] < max_distance
          else
            node_distances[node] <= max_distance
          end
        end

        def reachable_hex?(entity, hex)
          max_distance = @game.biggest_train(entity).distance
          return false if max_distance.zero?

          node_distances = @game.node_distances(entity)
          path_distances = @game.path_distances(entity)
          return false unless hex.tile.paths.any? { |p| path_distances[p] }

          # tile currently on network
          if hex.tile.nodes.any?
            # tile has a city/town/halt
            hex.tile.nodes.each do |tile_node|
              nd = node_distances[tile_node] if node_distances[tile_node]
              if tile_node.city? || tile_node.offboard?
                return true if nd && nd < max_distance
              elsif nd && nd <= max_distance
                return true
              end
            end
          else
            # tile is just track
            # Assumption: 1860 has no tiles that have track that doesn't connect to a node on the same tile
            hex.tile.paths.each do |tile_path|
              pd = path_distances[tile_path] if path_distances[tile_path]
              return true if pd && pd <= max_distance
            end
          end

          false
        end

        def available_hex(entity, hex)
          return false unless (neighbors = @game.graph.connected_hexes(entity)[hex])

          # laying yellow always OK
          return true if hex.tile.color == :white

          return true if reachable_hex?(entity, hex)

          # upgrades subject to train size
          max_distance = @game.biggest_train(entity).distance
          return false if max_distance.zero?

          path_distances = @game.path_distances(entity)
          return false if hex.tile.paths.any? { |p| path_distances[p] }

          # tile is currently not on network (it should be a neighbor to one that is)
          # We err on the side of caution, final determination needs to be based on actual tile placed
          neighbors.each do |edge|
            nhex = hex.neighbors[edge]
            nedge = hex.invert(edge)

            # find path on network that connects to that edge (1860 can only have one)
            npath = nhex.tile.paths.find { |p| path_distances[p] && p.exits.include?(nedge) }
            next unless npath

            return true if hex.tile.cities.any? && path_distances[npath] < max_distance
            return true if hex.tile.cities.empty? && path_distances[npath] <= max_distance
          end

          false
        end

        def hex_neighbors(entity, hex)
          @game.graph.connected_hexes(entity)[hex]
        end
      end
    end
  end
end
