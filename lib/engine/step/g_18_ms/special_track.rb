# frozen_string_literal: true

require_relative '../special_track'
require_relative 'lay_tile_with_chattanooga_check'

module Engine
  module Step
    module G18MS
      class SpecialTrack < SpecialTrack
        include LayTileWithChattanoogaCheck

        def unpass!
          super

          # If private P2 was used once it cannot be used again
          tile_lay = @game.p2_company.abilities(:tile_lay)
          tile_lay.use! if tile_lay&.count == 1
        end
      end
    end
  end
end
