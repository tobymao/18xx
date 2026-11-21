# frozen_string_literal: true

require_relative '../../../step/special_token'
require_relative 'half_price_token'

module Engine
  module Game
    module G18MO
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          include HalfPriceToken

          def available_hex(entity, hex)
            corporation = @game.token_owner(entity)
            corporation.abilities.any? { |a| a.type == :token && a.hexes.include?(hex.id) } ||
              @game.token_graph_for_entity(corporation).reachable_hexes(corporation)[hex]
          end

          def process_place_token(action)
            entity = action.entity

            hex = action.city.hex
            city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(entity, hex)

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
        end
      end
    end
  end
end
