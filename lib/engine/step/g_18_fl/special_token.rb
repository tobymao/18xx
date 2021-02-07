# frozen_string_literal: true

require_relative '../special_token'

module Engine
  module Step
    module G18FL
      class SpecialToken < SpecialToken
        def process_place_token(action)
          entity = action.entity

          hex = action.city.hex
          city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
          raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(entity, hex)

          place_token(
            @game.current_entity,
            action.city,
            action.token,
            teleport: ability(entity).teleport_price,
            special_ability: ability(entity),
          )
          entity.close!
          @game.log << "#{entity.name} closes"
        end

        def available_tokens(entity)
          return super unless ability(entity)&.extra

          [Engine::Token.new(@game.current_entity)]
        end

        def adjust_token_price_ability!(entity, _token, _hex, _city, special_ability = nil)
          token = Engine::Token.new(entity)
          token.price = special_ability.teleport_price
          [token, special_ability]
        end
      end
    end
  end
end
