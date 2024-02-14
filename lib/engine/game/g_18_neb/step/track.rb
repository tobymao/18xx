# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Neb
      module Step
        class Track < Engine::Step::Track
          def process_lay_tile(action)
            old_tile = action.hex.tile
            super
            @game.after_tile_lay(action.hex, old_tile, action.tile)
          end

          def legal_tile_rotation?(entity, hex, tile)
            old_tile = hex.tile
            if @game.town_to_city_upgrade?(old_tile, tile) || @game.omaha_green_upgrade?(old_tile, tile)
              return (old_tile.exits & tile.exits) == old_tile.exits
            end

            super
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
