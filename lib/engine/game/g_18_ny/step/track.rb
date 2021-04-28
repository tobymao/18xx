# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18NY
      module Step
        class Track < Engine::Step::Track
          def process_lay_tile(action)
            old_tile = action.hex.tile
            super
            @game.tile_lay(action.hex, old_tile, action.tile)
          end

          # Prevent terrain discounts from being applied implicitly.
          def border_cost_discount(_entity, _spender, _border, _cost, _hex)
            0
          end
        end
      end
    end
  end
end
