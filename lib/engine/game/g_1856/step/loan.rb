# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1856
      module Step
        class Loan < Engine::Step::Base
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            actions = []
            actions << 'payoff_loan' if can_payoff?(entity) || must_payoff?(entity)
            actions << 'take_loan' if @game.can_take_loan?(entity)
            actions << 'pass' if blocks? && !actions.empty?

            actions
          end

          def description
            can_payoff?(current_entity) ? 'Payoff Loans' : 'Take Loans'
          end

          def can_payoff?(entity)
            (loan = entity.loans[0]) &&
              entity.cash >= loan.amount &&
              @round.step_passed?(Engine::Step::BuyTrain)
          end

          def must_payoff?(entity)
            entity.loans.size > @game.maximum_loans(entity) && @round.step_passed?(Engine::Step::BuyTrain)
          end

          def blocks?
            return false if @game.post_nationalization

            @round.step_passed?(Engine::Step::BuyTrain)
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
            raise GameError, "Loan doesn't belong to that entity" unless entity.loans.include?(loan)

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
end
