# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G1864
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def description
            'Place extra station'
          end

          def available_tokens(entity)
            ability = ability(entity)
            return super if !ability || ability.from_owner

            [Engine::Token.new(entity.owner, price: ability.price)]
          end

          def process_place_token(action)
            super
            corporation = action.entity.owner
            @game.record_extra_station!(action.entity, action.city.tokens.find { |t| t&.corporation == corporation })
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            placed_hexes = entity.tokens.select(&:used).map { |t| t.city.hex }
            token, ability = super
            token.price = special_ability.price * placed_hexes.map { |placed| placed.distance(hex) }.min
            [token, ability]
          end
        end
      end
    end
  end
end
