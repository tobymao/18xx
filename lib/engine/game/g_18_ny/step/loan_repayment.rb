# frozen_string_literal: true

require_relative 'base'

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

            while can_payoff?(entity) || (entity.loans > entity.num_player_shares)
              @game.repay_loan(entity, entity.loans.first)
            end
          
            if entity.cash.negative?
              owner = entity.owner
              owner.spend(entity.cash.abs, @game.bank, check_cash: false)
              @round.cash_crisis_player = owner if owner.cash.negative?
            end
            
            @game.calculate_corporation_interest(entity)
          end
        end
      end
    end
  end
end
