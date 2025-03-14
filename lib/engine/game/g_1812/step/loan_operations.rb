# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_1867/step/loan_operations'

module Engine
  module Game
    module G1812
      module Step
        class LoanOperations < G1867::Step::LoanOperations
          def unpaid_interest(entity, owed)
            @log << "#{entity.name} owes #{format_currency(owed)} in loan interest but has #{format_currency(entity.cash)}"
            @log << "#{entity.name} will pay all remaining treasury cash (#{format_currency(entity.cash)}) to the "\
                    'bank and its stock price will drop one space'
            @game.unpaid_loan(entity, owed)
          end
        end
      end
    end
  end
end
