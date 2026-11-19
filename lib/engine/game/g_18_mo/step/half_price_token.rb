# frozen_string_literal: true

module Engine
  module Game
    module G18MO
      module Step
        module HalfPriceToken
          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            token, ability = super
            return [token, ability] unless half_price_token_ability?(ability)

            destination = destination_token_ability(entity, hex, city)
            return [token, ability] unless destination

            token.price = destination_token_price(entity, destination, hex)
            token.price = (token.price - (token.price * ability.discount)).to_i
            entity.remove_ability(destination)

            [token, ability]
          end

          def half_price_token_ability?(ability)
            ability&.type == :token && ability.owner == @game.company_by_id('HPTOK')
          end

          def destination_token_ability(entity, hex, city)
            entity.all_abilities.find do |ability|
              ability.type == :token &&
                ability.owner == entity &&
                ability.hexes.include?(hex.id) &&
                (!ability.city || ability.city == city.index)
            end
          end

          def destination_token_price(entity, ability, hex)
            return ability.price if @game.token_graph_for_entity(entity).reachable_hexes(entity)[hex]

            ability.teleport_price || ability.price
          end
        end
      end
    end
  end
end
