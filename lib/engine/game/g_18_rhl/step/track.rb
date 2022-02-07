# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhl
      module Step
        class Track < Engine::Step::Track
          include LayTileChecks

          def actions(entity)
            # Do not allow any tile lay if tokening has been used
            return [] if @round.tokened

            super
          end

          FOUR_SPOKERS_TO = %w[87 88 204].freeze

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if FOUR_SPOKERS_TO.include?(new_tile.name)

            super
          end
        end
      end
    end
  end
end
