# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18MO
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_hex(entity, hex)
            corporation = @game.token_owner(entity)
            destination_ability(corporation, hex) ||
              @game.token_graph_for_entity(corporation).reachable_hexes(corporation)[hex]
          end

          def process_place_token(action)
            entity = action.entity

            hex = action.city.hex
            if !@game.loading && !available_hex(entity, hex)
              city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
              raise GameError, "Cannot place token on #{hex.name}#{city_string}"
            end

            ability = ability(entity)
            check_connected = ability.type == :token && !ability.teleport_price

            place_token(
              @game.token_owner(entity),
              action.city,
              action.token,
              connected: check_connected,
              special_ability: ability,
            )

            teleport_complete if @round.teleported
            @game.remove_teleport_destination(entity, action.city)
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            token, ability = super
            return [token, ability] unless (destination = destination_ability(entity, hex))

            reachable = @game.token_graph_for_entity(entity).reachable_hexes(entity)[hex]
            token.price = reachable ? destination.price : destination.teleport_price
            token.price = ability.price(token).to_i
            entity.remove_ability(destination)

            [token, ability]
          end

          def destination_ability(corporation, hex)
            corporation.abilities.find { |a| a.type == :token && a.hexes.include?(hex.id) }
          end
        end
      end
    end
  end
end
