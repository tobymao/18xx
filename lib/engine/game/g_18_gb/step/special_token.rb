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

          def adjust_token_price_ability!(_entity, token, hex, _city, special_ability: nil)
            # we have to override this because the default method checks for abilities on the placing entity and connectivity
            # (for the teleport check) to the same entity, but we have the ability on the company and connectivity traced to the
            # corporation
            return [token, nil] unless special_ability

            corporation = token.corporation
            if @game.token_graph_for_entity(corporation).reachable_hexes(corporation)[hex]
              token.price = special_ability.price(token)
            elsif special_ability.teleport_price
              token.price = special_ability.teleport_price
            end

            [token, special_ability]
          end

          def switch_for_expensive_token(token)
            return token unless token.price.zero?

            current_entity.tokens.reject(&:used).max_by(&:price)
          end

          def process_place_token(action)
            hex = action.city.hex
            city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(action.entity, hex)

            token = switch_for_expensive_token(action.token)
            action.city.remove_reservation!(action.entity)

            place_token(
              action.entity,
              action.city,
              token,
              connected: false,
              special_ability: ability(action.entity),
              spender: current_entity,
            )

            @game.add_new_special_green_hex(current_entity, hex.coordinates)
            teleport_complete if @round.teleported
          end
        end
      end
    end
  end
end
