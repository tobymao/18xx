# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_1867/step/loan_operations'

module Engine
  module Game
    module G1812
      module Step
        class LoanOperations < G1867::Step::LoanOperations
          def skip!
            pass!
            entity = current_entity

            owed = @game.pay_interest!(entity)
            if owed
              current_cash = entity.cash
              @log << "#{entity.name} owes #{@game.format_currency(owed)} in loan "\
                      "interest but only has #{@game.format_currency(entity.cash)}"
              @log << "#{entity.name} will pay all remaining treasury cash (#{@game.format_currency(current_cash)}) to the "\
                      'bank and its stock price will drop one space'
              entity.spend(current_cash, bank)
              @game.stock_market.move_left(entity)
              return
            end

            @game.repay_loan(entity, entity.loans.first) while can_payoff?(entity)
            @game.calculate_corporation_interest(entity)
          end
        end
      end
    end
  end
end
