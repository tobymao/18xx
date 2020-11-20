# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1867
      class Loan < Base
        # @todo: this loan must restrict when available to certain actions
        def actions(entity)
          return [] if !entity.corporation? || entity != current_entity

          actions = []
          actions << 'payoff_loan' if can_payoff?(entity)
          actions << 'take_loan' if @game.can_take_loan?(entity)
          actions << 'pass' if blocks?

          actions
        end

        def description
          can_payoff?(current_entity) ? 'Payoff Loans' : 'Take Loans'
        end

        def can_payoff?(entity)
          @round.paid_loans[entity] &&
            (loan = entity.loans[0]) &&
            entity.cash >= loan.amount &&
            !@after_payoff_loan
        end

        def blocks?
          can_payoff?(current_entity) || (
            @round.paid_loans[current_entity] &&
            @game.can_take_loan?(current_entity)
          )
        end

        def process_take_loan(action)
          entity = action.entity
          @after_payoff_loan = true if @round.paid_loans[entity]
          @game.take_loan(entity, action.loan)
        end

        def process_payoff_loan(action)
          entity = action.entity
          loan = action.loan
          amount = loan.amount
          @log << "#{entity.name} pays off a loan for #{@game.format_currency(amount)}"
          @game.repay_loan(entity, loan)
        end

        def setup
          # you cannot payoff loans that you've taken after the payoff step
          @after_payoff_loan = false
        end
      end
    end
  end
end
