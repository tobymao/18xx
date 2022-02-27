# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18Rhl
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def ability(entity)
            return unless entity
            return if entity != @round.teleported || !entity.corporation? || entity.receivership?

            # As the ability is player owned instead of owned by current entity
            # we have saved it when doing teleport, and now we return it.
            @round.teleport_ability
          end

          def adjust_token_price_ability!(entity, token, _hex, _city, special_ability: nil)
            return super unless entity == @game.trajektanstalt

            # Need to override this as base implementation otherwise change token price to 0.
            # In 18Rhl the full current price is paid for teleported token for Private 4.
            [token, special_ability]
          end

          def process_place_token(action)
            return super unless @round.teleported

            entity = action.entity

            hex = action.city.hex
            city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(entity, hex)

            place_token(
              @round.teleported,
              action.city,
              action.token,
              connected: false,
              special_ability: ability(entity),
              spender: @game.current_entity,
            )

            teleport_complete
          end

          def teleport_complete
            super

            @round.teleport_ability = nil
          end
        end
      end
    end
  end
end
