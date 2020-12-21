# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1867
      class LoanOperations < Base
        ACTIONS = %w[payoff_loan pass].freeze
        def actions(_entity)
          # Repaying loans are automatic, but this hooks into the skip
          []
        end

        def can_payoff?(entity)
          entity.loans.any? &&
          entity.cash >= entity.loans.first.amount
        end

        def skip!
          pass!
          entity = current_entity

          owed = @game.pay_interest!(entity)
          if owed
            nationalize!(entity)
            # @todo: will this skip the rest of the entities turn?
            return
          end

          @game.repay_loan(entity, entity.loans.first) while can_payoff?(entity)
        end
      end
    end
  end
end
