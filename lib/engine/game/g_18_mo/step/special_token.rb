# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18MO
      module Step
        class SpecialToken < Engine::Step::SpecialToken
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
          end
        end
      end
    end
  end
end
