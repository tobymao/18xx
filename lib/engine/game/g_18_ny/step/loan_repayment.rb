# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class LoanRepayment < Engine::Step::Base
          def actions(_entity)
            # Repaying loans is automatic, but this hooks into the skip
            []
          end

          def can_payoff?(entity)
            entity.loans.any? &&
            entity.cash >= entity.loans.first.amount
          end

          def skip!
            pass!
            entity = current_entity

            @game.repay_loan(entity,
                             entity.loans.first) while can_payoff?(entity) || (entity.loans.size > entity.num_player_shares)
          end
        end
      end
    end
  end
end
