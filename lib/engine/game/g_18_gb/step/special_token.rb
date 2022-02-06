# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18GB
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_tokens(_entity)
            super(current_entity)
          end

          def process_place_token(action)
            hex = action.city.hex
            city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(action.entity, hex)

            action.city.remove_reservation!(action.entity)

            place_token(
              action.entity,
              action.city,
              action.token,
              connected: false,
              special_ability: ability(action.entity),
              spender: current_entity,
            )

            teleport_complete if @round.teleported
          end
        end
      end
    end
  end
end
