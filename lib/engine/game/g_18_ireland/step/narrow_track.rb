# frozen_string_literal: true

module Engine
  module Game
    module G18Ireland
      module Step
        module NarrowTrack
          def process_lay_tile(action)
            super
            @game.clear_narrow_graph
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            connected_paths = if @game.tile_uses_broad_rules?(old_tile, new_tile)
                                @game.graph_for_entity(entity).connected_paths(entity)
                              else
                                # Must update the graph now.
                                @game.clear_narrow_graph
                                @game.narrow_connected_paths(entity)
                              end

            old_paths = old_tile.paths
            changed_city = false
            used_new_track = old_paths.empty?

            new_tile.paths.each do |np|
              next unless connected_paths[np]

              op = old_paths.find { |path| np <= path }
              used_new_track = true unless op
              old_revenues = op&.nodes && op.nodes.map(&:max_revenue).sort
              new_revenues = np&.nodes && np.nodes.map(&:max_revenue).sort
              changed_city = true unless old_revenues == new_revenues
            end

            case @game.class::TRACK_RESTRICTION
            when :permissive
              true
            when :city_permissive
              raise GameError, 'Must be city tile or use new track' if new_tile.cities.none? && !used_new_track
            when :restrictive
              raise GameError, 'Must use new track' unless used_new_track
            when :semi_restrictive
              raise GameError, 'Must use new track or change city value' if !used_new_track && !changed_city
            else
              raise
            end
          end

          def all_hex_neighbors(entity, hex)
            # Legal tile rotation enforces gauge connectivity, return a union of both narrow and broad
            neighbors = (@game.graph_for_entity(entity).connected_hexes(entity)[hex] || []) |
             (@game.narrow_connected_hexes(entity)[hex] || [])
            return nil if neighbors.empty?

            neighbors
          end

          def legal_tile_rotation?(entity, hex, tile)
            return false unless @game.legal_tile_rotation?(entity, hex, tile)

            # this is the same as the base definition but with the 1867 check removed
            # this seems to have a problem with the DD tile.
            # @todo: fix the base defintion.

            old_paths = hex.tile.paths
            old_ctedges = hex.tile.city_town_edges

            new_paths = tile.paths
            new_exits = tile.exits
            new_ctedges = tile.city_town_edges
            extra_cities = [0, new_ctedges.size - old_ctedges.size].max

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              old_paths.all? { |path| new_paths.any? { |p| path <= p } } &&
              # Count how many cities on the new tile that aren't included by any of the old tile.
              # Make sure this isn't more than the number of new cities added.
              # 1836jr30 D6 -> 54 adds more cities
              extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } }
          end
        end
      end
    end
  end
end
