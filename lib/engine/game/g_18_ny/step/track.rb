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

          # Tile discount ability closes P1. Do not use implicitly.
          def border_cost_discount(_entity, _border, _hex)
            0
          end
        end
      end
    end
  end
end
