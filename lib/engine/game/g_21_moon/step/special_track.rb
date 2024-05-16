# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G21Moon
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            super

            @round.num_laid_track -= 1
          end

          def track_upgrade?(_from, _to, _hex)
            false
          end
        end
      end
    end
  end
end
