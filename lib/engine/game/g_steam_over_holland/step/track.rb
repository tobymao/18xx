# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class Track < Engine::Step::Track
          def update_token!(action, entity, tile, old_tile)
            return if tile.hex.id == 'F9'

            super
          end

          def border_cost_discount(_entity, _spender, _border, _cost, _hex)
            0
          end
        end
      end
    end
  end
end
