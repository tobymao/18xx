# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative '../../../part/future_label'

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
            super

            return if action.tile.color != :brown

            case action.tile.hex.id
            when 'B11'
              action.tile.future_label = Engine::Part::FutureLabel.new('K', 'gray')
            when 'C18'
              action.tile.future_label = Engine::Part::FutureLabel.new('L', 'gray')
            end
          end
        end
      end
    end
  end
end
