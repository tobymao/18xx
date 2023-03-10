# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Mag
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity != current_entity && !ability(entity)
            return [] if entity.corporation? && entity.receivership?
            return [] unless can_place_token?(current_entity)

            ACTIONS
          end

          def can_place_token?(entity)
            (tokens = available_tokens(entity)).any? &&
            min_token_price(tokens) <= buying_power(entity) &&
            (entity.corporation? || @game.graph.can_token?(entity))
          end

          def available_tokens(entity)
            entity = current_entity if current_entity
            token_holder = entity.company? ? entity.owner : entity
            token_holder.tokens_by_type
          end

          def pay_token_cost(entity, cost)
            return super unless entity.minor?

            skev_income = (cost / 2).to_i
            entity.spend(cost - skev_income, @game.bank)
            entity.spend(skev_income, @game.skev)

            @log << "#{@game.skev.name} earns #{@game.format_currency(skev_income)}"
          end

          def process_place_token(action)
            entity = action.entity
            entity = current_entity if entity.company?
            special_ability = ability(action.entity)
            place_token(entity, action.city, action.token, connected: !entity.corporation?, special_ability: special_ability)
            special_ability&.use!
            pass!
          end

          def available_hex(entity, hex)
            entity = current_entity if entity.company?
            if entity.minor?
              @game.graph.reachable_hexes(entity)[hex]
            else
              hex.tile.cities.any? { |c| c.available_slots.positive? }
            end
          end

          def ability(entity)
            return unless entity&.company?

            @game.abilities(entity, :token) do |ability, _company|
              return ability
            end

            nil
          end
        end
      end
    end
  end
end
