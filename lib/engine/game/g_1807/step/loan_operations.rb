# frozen_string_literal: true

require_relative '../../g_1867/step/loan_operations'

module Engine
  module Game
    module G1807
      module Step
        class LoanOperations < G1867::Step::LoanOperations
          def interest_unpaid!(corporation, owed)
            cash = corporation.cash
            @log << "#{corporation.name} owes #{@game.format_currency(owed)} " \
                    "in loan interest but only has #{@game.format_currency(cash)}"
            if cash.positive?
              @log << "#{corporation.name} pays #{@game.format_currency(cash)} " \
                      "loan interest"
              corporation.spend(cash, @game.bank)
            end
            share_price = corporation.share_price
            @game.stock_market.move_left(corporation)
            @game.log_share_price(corporation, share_price)
          end
        end
      end
    end
  end
end
