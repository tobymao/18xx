# frozen_string_literal: true

require_relative '../special_token'

module Engine
  module Step
    module G18FL
      class SpecialToken < SpecialToken
        def can_lay_token?(tokener)
          !@game.round.laid_token[tokener] &&
          @game.round.steps.any? { |step| step.passed? && step.is_a?(Step::G18FL::Track) } &&
          @game.round.steps.none? { |step| step.passed? && step.is_a?(Step::Route) }
        end

        def process_place_token(action)
          tokener = @game.current_entity
          raise GameError, 'Terminal Company cannot lay token now' unless can_lay_token?(tokener)

          entity = action.entity

          hex = action.city.hex
          city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
          raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(entity, hex)

          place_token(
            tokener,
            action.city,
            action.token,
            teleport: ability(entity).teleport_price,
            special_ability: ability(entity),
          )
          entity.close!
          @game.log << "#{entity.name} closes"
          @game.round.laid_token[tokener] = true
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
