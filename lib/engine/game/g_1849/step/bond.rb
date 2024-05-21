# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
      module Step
        class Bond < Engine::Step::Base
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            actions = []
            actions << 'payoff_loan' if can_payoff_loan?(entity)
            actions << 'take_loan' if @game.can_take_loan?(entity)
            actions << 'pass' if blocks? && !actions.empty?

            actions
          end

          def description
            can_payoff_loan?(current_entity) ? 'Repay Bond' : 'Issue Bond'
          end

          def log_skip(entity)
            super if @game.bonds? && !@game.phase.status.include?('gray_uses_white')
          end

          def take_loan_button_text
            "Issue Bond (#{@game.format_currency(@game.loan_value)})"
          end

          def payoff_loan_button_text
            "Repay Bond (#{@game.format_currency(@game.loan_value)})"
          end

          def can_payoff_loan?(entity)
            !@round.issued_bond[entity] &&
              entity.loans.any? &&
              entity.cash >= entity.loans.first.amount
          end

          def process_take_loan(action)
            raise GameError, 'Cannot issue bond' unless @game.can_take_loan?(action.entity)

            @game.take_loan(action.entity, action.loan)
          end

          def process_payoff_loan(action)
            entity = action.entity
            loan = action.loan
            amount = loan.amount
            raise GameError, "Bond doesn't belong to that entity" unless entity.loans.include?(loan)

            @log << "#{entity.name} repays its outstanding bond for #{@game.format_currency(amount)}"
            entity.spend(amount, @game.bank)

            entity.loans.delete(loan)
            @game.loans << loan
            @round.repaid_bond[entity] = true

            initial_sp = entity.share_price.price
            @game.stock_market.move_right(entity)
            @log << "#{entity.name}'s share price changes from" \
                    " #{@game.format_currency(initial_sp)} to #{@game.format_currency(entity.share_price.price)}"
          end
        end
      end
    end
  end
end
