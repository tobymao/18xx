# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1856
      class Loan < Base
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
          (loan = entity.loans[0]) &&
            entity.cash >= loan.amount &&
            @round.steps.any? { |step| step.passed? && step.is_a?(Step::BuyTrain) }
        end

        def blocks?
          @round.steps.any? { |step| step.passed? && step.is_a?(Step::BuyTrain) }
        end

        def process_take_loan(action)
          entity = action.entity
          @game.take_loan(entity, action.loan)
          @round.took_loan[entity] = true
        end

        def process_payoff_loan(action)
          entity = action.entity
          loan = action.loan
          amount = loan.amount
          @game.game_error("Loan doesn't belong to that entity") unless entity.loans.include?(loan)

          @log << "#{entity.name} pays off a loan for #{@game.format_currency(amount)}"
          entity.spend(amount, @game.bank)

          entity.loans.delete(loan)
          @game.loans << loan
          @round.redeemed_loan[entity] = true
        end
      end
    end
  end
end
