# frozen_string_literal: true

require_relative '../../g_1846/step/track_and_token'

module Engine
  module Game
    module G18MO
      module Step
        class TrackAndToken < G1846::Step::TrackAndToken
          def process_place_token(action)
            super

            @game.remove_teleport_destination(action.entity, action.city)
          end

          def available_hex(entity, hex)
            return tokener_available_hex(current_entity, hex) if hptok_company?(entity)

            super
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            return [token, nil] if @hptok_price_set

            super
          end

          def tokener_available_hex(entity, hex)
            entity.all_abilities.each do |ability|
              return true if ability.type == :token && ability.hexes.include?(hex.id)
            end
            super
          end

          private

          def hptok_company?(entity)
            entity == @game.company_by_id('HPTOK')
          end
        end
      end
    end
  end
end
