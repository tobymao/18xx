# frozen_string_literal: true

require_relative 'base'

module Engine
  module Game
    module G18NY
      module Step
        class LoanInterestPayment < Engine::Step::Base
          def actions(_entity)
            # Repaying interest is automatic, but this hooks into the skip
            []
          end

          def skip!
            pass!
            entity = current_entity

            owed = @game.pay_interest!(entity)

            # This case only occurs if the corporation can't pay all the interest
            if owed.positive?
              owed -= entity.cash
              @log << "#{entity.name} pays #{format_currency(entity.cash)} interest for #{loans}"
              entity.spend(entity.cash, @game.bank)

              owner = entity.owner
              owner.spend(owed, @game.bank, check_cash: false)
              @round.cash_crisis_player = owner if owner.cash.negative?
            end
          end
        end
      end
    end
  end
end
