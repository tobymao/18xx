# frozen_string_literal: true

module Engine
  module Game
    module G18MO
      module Step
        module HalfPriceToken
          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            token, ability = super
            return [token, ability] unless ability&.owner&.id == 'HPTOK'

            destination = entity.abilities.find { |a| a.type == :token && a.hexes.include?(hex.id) }
            return [token, ability] unless destination

            reachable = @game.token_graph_for_entity(entity).reachable_hexes(entity)[hex]
            token.price = reachable ? destination.price : destination.teleport_price
            token.price = ability.price(token).to_i
            entity.remove_ability(destination)

            [token, ability]
          end
        end
      end
    end
  end
end
