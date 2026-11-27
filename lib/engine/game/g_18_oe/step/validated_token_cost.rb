# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Step
        module ValidatedTokenCost
          private

          def validated_token_cost(action, cost)
            return cost if !action.cost || action.cost == cost

            raise GameError, "Token costs #{@game.format_currency(cost)}, not #{@game.format_currency(action.cost)}"
          end
        end
      end
    end
  end
end
