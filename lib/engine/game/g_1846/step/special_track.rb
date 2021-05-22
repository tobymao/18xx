# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1846
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            @game.remove_lm_icons if action.entity.id == 'LM'
            @game.remove_lsl_icons if action.entity.id == 'LSL'

            super
          end
        end
      end
    end
  end
end
