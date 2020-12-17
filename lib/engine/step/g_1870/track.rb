# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'

module Engine
  module Step
    module G1870
      class Track < Track
        def lay_tile(action, extra_cost: 0, entity: nil)
          @game.game_error('Cannot upgrade the tile in the same turn') if action.hex == @round.river_special_tile_lay

          super
        end
      end
    end
  end
end
