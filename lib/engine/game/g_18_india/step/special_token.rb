# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18India
      module Step
        class SpecialToken < Engine::Step::SpecialToken

          # Check using current entity?
          def actions(entity)
            entity = current_entity if entity.player?
            return [] if !ability(entity) || available_tokens(entity).empty?

            actions = ['place_token']
            actions << 'pass' if entity == @round.teleported
            actions
          end

          def process_place_token(action)
            entity = action.entity
            corp = current_entity

            hex = action.city.hex
            city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(corp, hex)

            special_ability = ability(entity)
            check_tokenable =
              if special_ability.respond_to?(:check_tokenable)
                special_ability.check_tokenable
              else
                true
              end

            connected = special_ability.type == :token ? special_ability.connected : false
            place_token(
              @game.token_owner(corp),
              action.city,
              action.token,
              connected: connected,
              special_ability: special_ability,
              check_tokenable: check_tokenable,
            )

            if special_ability.type == :token
              special_ability.use!

              if special_ability.count&.zero? && special_ability.closed_when_used_up
                company = special_ability.owner
                @game.company_is_closing(company)
                company.close!
              end
            end

            teleport_complete if @round.teleported
          end

        end
      end
    end
  end
end
