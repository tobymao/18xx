# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_1817/step/dividend'

module Engine
  module Game
    module G18USA
      module Step
        class Loan < G1817::Step::Loan
          def process_payoff_loan(action)
            entity = action.entity
            loan = action.loan
            amount = loan.amount
            raise GameError, "Loan doesn't belong to that entity" unless entity.loans.include?(loan)

            @log << "#{entity.name} pays off a loan for #{@game.format_currency(amount)}"
            entity.spend(amount, @game.bank)

            entity.loans.delete(loan)
            @game.loans << loan

            price = entity.share_price.price
            @game.stock_market.move_right(entity)
            @game.stock_market.move_right(entity)
            @game.log_share_price(entity, price)
          end
        end
      end
    end
  end
end
