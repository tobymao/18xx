# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Cuba
      module Step
        class Dividend < Engine::Step::Dividend
          def process_dividend(action)
            entity = action.entity
            revenue = total_revenue
            super

            @game.sugar_production(entity, revenue)
          end
        end
      end
    end
  end
end
