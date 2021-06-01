# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1856
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            if action.hex.id == 'I12'
              # Action hex is I12 if and only if private used was Waterloo & Saugeen
              @game.log << "#{@game.wsrc.name} is used and will close at the end of the operating round"
              @round.wsrc_activated = true
            end
            super
          end
        end
      end
    end
  end
end
