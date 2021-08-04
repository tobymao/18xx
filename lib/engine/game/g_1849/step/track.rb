# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1849
      module Step
        class Track < Engine::Step::Track
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            old_tile = action.hex.tile
            action.tile.upgrades = old_tile.upgrades
            super
            old_tile.upgrades = []
          end

          def process_lay_tile(action)
            lay_tile_action(action)
            action.entity.sms_hexes = [action.hex.id] if action.entity.sms_hexes

            @game.update_garibaldi

            pass!
          end

          def available_hex(entity, hex)
            return super unless entity.sms_hexes

            return [0, 1, 2, 3, 4, 5] if entity.sms_hexes.find { |h| h == hex.id }
          end

          def hex_neighbors(entity, hex)
            return super unless entity.sms_hexes

            return [0, 1, 2, 3, 4, 5] if entity.sms_hexes.find { |h| h == hex.id }
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            super unless entity.sms_hexes
          end
        end
      end
    end
  end
end
