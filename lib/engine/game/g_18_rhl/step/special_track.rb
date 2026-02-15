# frozen_string_literal: true

require_relative '../../g_18_rhineland/step/special_track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhl
      module Step
        class SpecialTrack < G18Rhineland::Step::SpecialTrack
          include LayTileChecks

          def restricted_private_in_yellow_phase(entity)
            super || entity == @game.angertalbahn
          end
        end
      end
    end
  end
end
