# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1866
      module Step
        class LoanRepayment < Engine::Step::Base
          ACTIONS = %w[payoff_loan pass].freeze

          def actions(entity)
            return [] if entity != current_entity || !entity.corporation? || !@game.corporation?(entity) || !can_payoff?(entity)

            ACTIONS
          end

          def description
            'Repay loans'
          end

          def process_payoff_loan(action)
            @game.payoff_loan(action.entity, action.loan)
          end

          def can_payoff?(entity)
            entity.loans.any? && entity.cash >= entity.loans.first.amount
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
