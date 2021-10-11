# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative '../../../step/track_lay_when_company_sold'

module Engine
  module Game
    module G18SJ
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            @game.special_tile_lay(action)

            super
          end
        end
      end
    end
  end
end
