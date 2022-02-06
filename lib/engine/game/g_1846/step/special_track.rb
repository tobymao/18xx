# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1846
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            if action.entity.id == @game.class::LSL_ID
              @game.remove_icons(@game.class::LSL_HEXES,
                                 @game.class::ABILITY_ICONS[action.entity.id])
            end

            super
            @game.place_token_on_upgrade(action)
          end
        end
      end
    end
  end
end
