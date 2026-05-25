# frozen_string_literal: true

require_relative '../../g_1846/step/track_and_token'
module Engine
  module Game
    module G18MO
      module Step
        class TrackAndToken < G1846::Step::TrackAndToken
          def actions(entity)
            return super unless hptok_company?(entity)
            return [] if entity.owner != current_entity || !can_place_token?(current_entity)

            ['place_token']
          end

          def process_place_token(action)
            if hptok_company?(action.entity)
              hptok_ability = action.entity.all_abilities.find { |a| a.type == :token && a.owner_type == 'corporation' }
              token = action.token
              hex = action.city.hex
              corp_ability = current_entity.all_abilities.find { |a| a.type == :token && a.hexes.include?(hex.id) }
              base_price = if corp_ability && @game.token_graph_for_entity(current_entity).reachable_hexes(current_entity)[hex]
                             corp_ability.price(token)
                           elsif corp_ability&.teleport_price
                             corp_ability.teleport_price
                           else
                             token.price
                           end
              token.price = (base_price * hptok_ability.discount).to_i
              @hptok_price_set = true
              place_token(current_entity, action.city, token)
              @hptok_price_set = false
              action.entity.remove_ability(hptok_ability)
              pass! unless can_lay_tile?(current_entity)
            else
              super
            end
            @game.remove_teleport_destination(current_entity, action.city)
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
