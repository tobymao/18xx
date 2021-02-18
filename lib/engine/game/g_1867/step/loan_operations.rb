# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1867
      module Step
        class LoanOperations < Engine::Step::Base
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
              @game.nationalize!(entity)
              # @todo: will this skip the rest of the entities turn?
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
