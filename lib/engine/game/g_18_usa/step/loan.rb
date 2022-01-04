# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../g_1817/step/dividend'

module Engine
  module Game
    module G18USA
      module Step
        class Loan < G1817::Step::Loan
          def can_payoff?(entity)
            super && !@loan_taken
          end

          def process_take_loan(action)
            super
            @loan_taken = true
          end

          def setup
            super
            @loan_taken = false
          end
        end
      end
    end
  end
end
