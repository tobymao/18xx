# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1870
      module Step
        class Track < Engine::Step::Track
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError,
                  'Cannot upgrade the tile in the same turn' if action.hex == @round.river_special_tile_lay

            super
          end
        end
      end
    end
  end
end
