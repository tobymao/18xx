# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1870
      module Step
        class Track < Engine::Step::Track
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            if action.hex == @round.river_special_tile_lay
              raise GameError,
                    'Cannot upgrade the tile in the same turn'
            end

            super
          end

          def process_lay_tile(action)
            old_tile = action.hex.tile

            super

            return unless old_tile.label.to_s == 'P'

            old_tile.label = nil if %i[yellow green].include?(old_tile.color)
            action.tile.label = 'P' if %i[yellow green].include?(action.tile.color)
          end
        end
      end
    end
  end
end
