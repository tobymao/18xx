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

            old_tile.label = nil if %i[yellow green].include?(old_tile.color)
            old_tile.label = 'P' if old_tile.id == '170'

            return if action.tile.color == 'gray'

            if action.tile.hex.id == 'B11'
              action.tile.label = 'K P'
            elsif action.tile.hex.id == 'C18'
              action.tile.label = 'P L'
            elsif %w[J3 J5 N17].include?(action.tile.hex.id)
              action.tile.label = 'P'
            end
          end
        end
      end
    end
  end
end
