# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1862
      module Step
        class HomeUpgrade < Engine::Step::Track
          def round_state
            {
              upgrade_before_token = []
            }
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity && @round.upgrade_before_token.include?(entity)
            return [] if entity.company? || !can_lay_tile?(entity)

            %w[lay_tile]
          end

          def process_lay_tile(action)
            lay_tile_action(action)

            @game.add_token(action.hex, action.tile, action.entity)
            @round.upgrade_before_token.delete(action.entity)
            pass!
          end

          def add_token(hex, entity)
            token = entity.find_token_by_type
            hex.tile.cities.first.place_token(corporation, token)
            @log << "#{entity.name} places home token on #{hex.name}"
          end

          # no graph at this point -> allow lay on home hex
          def available_hex(entity, hex)
            return nil unless entity.corporation?

            hex == @game.hex_by_id(corporation.coordinates)
          end
        end
      end
    end
  end
end
