# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1893
      module Step
        class Track < Engine::Step::Track
          def upgradeable_tiles(entity, hex)
            potential_tiles(entity, hex).map do |tile|
              if @game.leverkusen_upgrade_to_green?(hex, tile)
                leverkusen_only_legal_rotation(tile)
              else
                tile.rotate!(0) # reset tile to no rotation since calculations are absolute
                tile.legal_rotations = legal_tile_rotations(entity, hex, tile)
                next if tile.legal_rotations.empty?

                tile.rotate! # rotate it to the first legal rotation
                tile
              end
            end.compact
          end

          def leverkusen_only_legal_rotation(tile)
            tile.rotate!(0)
            tile
          end

          def legal_tile_rotation?(entity, hex, tile)
            return false unless @game.legal_tile_rotation?(entity, hex, tile)
            return true if @game.leverkusen_upgrade_to_green?(hex, tile)

            old_paths = hex.tile.paths
            old_ctedges = hex.tile.city_town_edges

            new_paths = tile.paths
            new_exits = tile.exits
            new_ctedges = tile.city_town_edges
            extra_cities = [0, new_ctedges.size - old_ctedges.size].max
            multi_city_upgrade = new_ctedges.size > 1 && old_ctedges.size > 1

            new_exits.all? { |edge| hex.neighbors[edge] } &&
              !(new_exits & hex_neighbors(entity, hex)).empty? &&
              old_paths.all? { |path| new_paths.any? { |p| path <= p } } &&
              # Count how many cities on the new tile that aren't included by any of the old tile.
              # Make sure this isn't more than the number of new cities added.
              # 1836jr30 D6 -> 54 adds more cities
              extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } } &&
              # 1867: Does every old city correspond to exactly one new city?
              (!multi_city_upgrade ||
               old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
          end
        end
      end
    end
  end
end
