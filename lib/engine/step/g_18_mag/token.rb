# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18Mag
      class Token < Token
        def actions(entity)
          return [] unless entity == current_entity
          return [] if entity.corporation? && entity.receivership?

          super
        end

        def can_place_token?(entity)
          current_entity == entity &&
            (tokens = available_tokens(entity)).any? &&
            min_token_price(tokens) <= buying_power(entity) &&
            (entity.corporation? || @game.graph.can_token?(entity))
        end

        def pay_token_cost(entity, cost)
          skev_income = (cost / 2).to_i
          entity.spend(cost - skev_income, @game.bank)
          entity.spend(skev_income, @game.skev)

          @log << "#{@game.skev.name} earns #{@game.format_currency(skev_income)}"
        end

        def available_hex(entity, hex)
          if entity.minor?
            @game.graph.reachable_hexes(entity)[hex]
          else
            hex.tile.cities.any? { |c| c.available_slots.positive? }
          end
        end
      end
    end
  end
end
