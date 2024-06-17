# frozen_string_literal: true

require_relative '../../g_1817/step/loan'

module Engine
  module Game
    module G18Hiawatha
      module Step
        class Loan < G1817::Step::Loan
          def can_payoff?(entity)
            @round.paid_loans[entity] &&
              (loan = entity.loans[0]) &&
              entity.cash >= loan.amount &&
              @round.payable_loans.positive? &&
              !@after_payoff_loan
          end

          def process_payoff_loan(action)
            raise GameError, 'Cannot pay off loans taken this OR.' unless @round.payable_loans.positive?

            super

            @round.payable_loans -= 1
            return if @round.payable_loans.positive?

            @log << "#{action.entity.id} has paid off all loans taken before this round"
          end
        end
      end
    end
  end
end
