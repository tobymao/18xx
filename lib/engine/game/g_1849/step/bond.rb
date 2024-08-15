# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
      module Step
        class Bond < Engine::Step::Base
          attr_reader :issued_bond, :redeemed_bond

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            actions = []
            actions << 'payoff_loan' if can_payoff_loan?(entity)
            actions << 'take_loan' if can_take_loan?(entity)
            actions << 'pass' if blocks? && !actions.empty?

            actions
          end

          def round_state
            @issued_bond = {}
            @redeemed_bond = {}
          end

          def description
            can_payoff_loan?(current_entity) ? 'Repay Bond' : 'Issue Bond'
          end

          def log_skip(entity)
            super if @game.bonds? && @game.issue_bonds_enabled
          end

          def take_loan_text
            "Issue Bond (#{@game.format_currency(@game.loan_value)})"
          end

          def payoff_loan_text
            "Repay Bond (#{@game.format_currency(@game.loan_value)})"
          end

          def take_loan(entity, loan)
            raise GameError, 'Cannot issue bond' unless can_take_loan?(entity)

            @log << "#{entity.name} issues its bond and receives #{@game.format_currency(@game.loan_value)}"
            @game.bank.spend(@game.loan_value, entity)
            entity.loans << loan
            @issued_bond[entity] = true

            initial_sp = entity.share_price.price
            @game.stock_market.move_left(entity)
            @log << "#{entity.name}'s share price changes from" \
                    " #{@game.format_currency(initial_sp)} to #{@game.format_currency(entity.share_price.price)}"
          end

          def can_take_loan?(entity)
            @game.bonds? &&
             @game.issue_bonds_enabled &&
             entity.corporation? &&
             !@redeemed_bond[entity] &&
             entity.loans.size < @game.maximum_loans(entity)
          end

          def can_payoff_loan?(entity)
            !@issued_bond[entity] &&
              !entity.loans.empty? &&
              entity.cash >= entity.loans.first.amount
          end

          def process_take_loan(action)
            raise GameError, 'Cannot issue bond' unless can_take_loan?(action.entity)

            take_loan(action.entity, action.loan)
          end

          def process_payoff_loan(action)
            entity = action.entity
            loan = action.loan
            amount = loan.amount
            raise GameError, "#{entity.name} cannot redeem bond" unless can_payoff_loan?(entity)

            @log << "#{entity.name} repays its outstanding bond for #{@game.format_currency(amount)}"
            entity.spend(amount, @game.bank)

            entity.loans.delete(loan)

            @redeemed_bond[entity] = true

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
