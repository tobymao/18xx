# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_1867/step/loan_operations'

module Engine
  module Game
    module G1812
      module Step
        class LoanOperations < G1867::Step::LoanOperations
          def interest_unpaid!(entity, owed)
            @log << "#{entity.name} owes #{@game.format_currency(owed)} in loan interest but has "\
                    "#{@game.format_currency(entity.cash)}"
            @log << "#{entity.name} will pay all remaining treasury cash (#{@game.format_currency(entity.cash)}) to the "\
                    'bank and its stock price will drop one space'
            @game.forfeit_cash!(entity)
          end
        end
      end
    end
  end
end
