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
              @game.unpaid_loan(entity, owed)
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
