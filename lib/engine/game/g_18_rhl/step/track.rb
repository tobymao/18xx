# frozen_string_literal: true

require_relative '../../g_18_rhineland/step/track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhl
      module Step
        class Track < G18Rhineland::Step::Track
          include LayTileChecks

          def skip_check_track_restrictions?(entity, old_tile, new_tile)
            return true if super

            @game.optional_promotion_tiles && old_tile.name == '929' && new_tile.name == '949'
          end
        end
      end
    end
  end
end
