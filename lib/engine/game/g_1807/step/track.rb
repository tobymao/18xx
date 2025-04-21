# frozen_string_literal: true

require_relative '../../g_1867/step/track'

module Engine
  module Game
    module G1807
      module Step
        class Track < G1867::Step::Track
          def available_hex(entity, hex)
            return super unless hex == @game.london_small

            london_available?(entity)
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            super

            @game.london_upgraded!(action.hex.tile) if action.hex == @game.london_small
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            return super unless hex == @game.london_small

            true
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            super unless new_tile.hex == @game.london_small
          end

          private

          def london_available?(entity)
            @game.london_zoomed.any? { |hex| available_hex(entity, hex) }
          end
        end
      end
    end
  end
end
