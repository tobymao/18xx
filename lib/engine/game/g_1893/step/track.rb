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
            return true if @game.leverkusen_upgrade_to_green?(hex, tile)

            super
          end
        end
      end
    end
  end
end
