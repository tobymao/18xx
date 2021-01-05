# frozen_string_literal: true

require_relative '../special_track'
require_relative '../track_lay_when_company_sold'

module Engine
  module Step
    module G18SJ
      class SpecialTrack < SpecialTrack
        def process_lay_tile(action)
          @game.special_tile_lay(action)

          super
        end
      end
    end
  end
end
