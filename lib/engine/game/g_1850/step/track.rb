# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1850
      module Step
        class Track < Engine::Step::Track
          P_HEXES = %w[J5 B11 C18 N17].freeze

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

            old_tile.label = nil if %i[yellow green].include?(old_tile.color) && old_tile.label.to_s == 'P'
            return unless P_HEXES.include?(action.hex.coordinates)

            action.tile.label = 'P' if %i[yellow green].include?(action.tile.color)
          end
        end
      end
    end
  end
end
