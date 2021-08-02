# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'tracker'

module Engine
  module Game
    module G1860
      module Step
        class Track < Engine::Step::Base
          include Engine::Game::G1860::Tracker
          ACTIONS = %w[lay_tile pass].freeze

          def actions(entity)
            return [] if entity.company? || !can_lay_tile?(entity)
            return [] if entity.receivership?
            return [] if @game.sr_after_southern

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

          def reachable_path?(entity, path, max_distance)
            return false if max_distance[0].zero?

            path_distances = @game.distance_graph.path_distances(entity)
            path_distances[path][0] <= max_distance[0] && path_distances[path][-1] <= max_distance[-1]
          end

          def reachable_city?(node_distance, train_distance)
            unused = train_distance[0] - node_distance[0] - 1

            node_distance[0] < train_distance[0] && node_distance[-1] <= train_distance[-1] + unused
          end

          def reachable_town?(node_distance, train_distance)
            unused = train_distance[0] - node_distance[0]

            node_distance[0] <= train_distance[0] && node_distance[-1] < train_distance[-1] + unused
          end

          def reachable_halt?(node_distance, train_distance)
            unused = train_distance[0] - node_distance[0]

            node_distance[0] <= train_distance[0] && node_distance[-1] <= train_distance[-1] + unused
          end

          def reachable_node?(entity, node, max_distance)
            return false if max_distance[0].zero?

            node_distances = @game.distance_graph.node_distances(entity)
            return false unless node_distances[node]

            if node.city?
              reachable_city?(node_distances[node], max_distance)
            elsif node.town? && !node.halt?
              reachable_town?(node_distances[node], max_distance)
            else
              reachable_halt?(node_distances[node], max_distance)
            end
          end

          def reachable_hex?(entity, hex, max_distance)
            node_distances = @game.distance_graph.node_distances(entity)
            path_distances = @game.distance_graph.path_distances(entity)
            return false unless hex.tile.paths.any? { |p| path_distances[p] }

            # tile currently on network
            if hex.tile.nodes.any?
              # tile has a city/town/halt
              hex.tile.nodes.each do |tile_node|
                nd = node_distances[tile_node]

                if tile_node.city? || tile_node.offboard?
                  return true if nd && reachable_city?(nd, max_distance)
                elsif tile_node.town? && !tile_node.halt?
                  return true if nd && reachable_town?(nd, max_distance)
                elsif nd && reachable_halt?(nd, max_distance)
                  return true
                end
              end
            else
              # tile is just track
              # Assumption: 1860 has no tiles that have track that doesn't connect to a node on the same tile
              hex.tile.paths.each do |tile_path|
                pd = path_distances[tile_path]

                return true if pd && reachable_halt?(pd, max_distance)
              end
            end

            false
          end

          def available_hex(entity, hex)
            return false unless (neighbors = @game.graph.connected_hexes(entity)[hex])

            # laying yellow always OK
            return true if hex.tile.color == :white

            # upgrades subject to train size
            max_distance = @game.biggest_train_distance(entity)
            return false if max_distance[0].zero?

            return true if reachable_hex?(entity, hex, max_distance)

            path_distances = @game.distance_graph.path_distances(entity)

            # tile is currently not on the reachable network (it should be a neighbor to one that is)
            # We err on the side of caution, final determination needs to be based on actual tile placed
            neighbors.each do |edge|
              nhex = hex.neighbors[edge]
              nedge = hex.invert(edge)

              # find path on network that connects to that edge (1860 can only have one)
              npath = nhex.tile.paths.find { |p| path_distances[p] && p.exits.include?(nedge) }
              next unless npath

              return true if hex.tile.cities.any? && reachable_city?(path_distances[npath], max_distance)
              return true if hex.tile.towns.any? do |t|
                               !t.halt?
                             end && reachable_town?(path_distances[npath], max_distance)
              return true if hex.tile.towns.any?(&:halt?) && reachable_halt?(path_distances[npath], max_distance)
              return true if hex.tile.nodes.empty? && reachable_halt?(path_distances[npath], max_distance)
            end

            false
          end
        end
      end
    end
  end
end
