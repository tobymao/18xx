# frozen_string_literal: true

require_relative '../../g_1817/step/loan'
require_relative 'scrap_train_module'

module Engine
  module Game
    module G18USA
      module Step
        class Loan < G1817::Step::Loan
          include ScrapTrainModule
          def actions(entity)
            actions = super
            return actions if actions.empty?

            actions << 'scrap_train' if entity == current_entity && can_scrap_train?(current_entity)
            actions
          end

          def can_payoff?(entity)
            super && !@loan_taken
          end

          def process_take_loan(action)
            super
            @loan_taken = true
          end

          def setup
            super
            @loan_taken = false
          end
        end
      end
    end
  end
end
