# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhineland
      module Step
        class Track < Engine::Step::Track
          include LayTileChecks

          def actions(entity)
            # Do not allow any tile lay if tokening has been used, or if receivership
            return [] if @round.tokened || entity.receivership?

            super
          end

          FOUR_SPOKERS_TO = %w[87 88 204].freeze

          def check_track_restrictions!(entity, old_tile, new_tile)
            super unless skip_check_track_restrictions?(entity, old_tile, new_tile)
          end

          def skip_check_track_restrictions?(_entity, _old_tile, new_tile)
            FOUR_SPOKERS_TO.include?(new_tile.name)
          end

          RHINE_METROPOLIS_HEXES = %w[D9 F9 I10].freeze

          def upgradeable_tiles(entity, hex)
            return super unless RHINE_METROPOLIS_HEXES.include?(hex.name)

            potential_tiles(entity, hex).map do |tile|
              tile.rotate!(0)
              tile
            end.compact
          end

          def legal_tile_rotation?(entity, hex, tile)
            return true if RHINE_METROPOLIS_HEXES.include?(hex.name)

            super
          end
        end
      end
    end
  end
end
