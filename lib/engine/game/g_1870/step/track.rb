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
            old_future_label = action.hex.tile.future_label

            super

            return if action.tile.color != :brown

            case action.tile.hex.id
            when 'B11'
              action.tile.future_label = old_future_label
              action.tile.future_label.label = 'K'
              action.tile.future_label.color = :gray
            when 'C18'
              action.tile.future_label = old_future_label
              action.tile.future_label.color = :gray
              action.tile.future_label.label = 'L'
            end
          end
        end
      end
    end
  end
end
