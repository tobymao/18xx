# frozen_string_literal: true

require_relative '../../../step/base'

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

            return unless (owed = @game.pay_interest!(entity))

            # This case only occurs if the corporation can't pay all the interest.
            # A negative cash value will trigger emergency money raising.
            num_loans = owed / @game.interest_rate
            loans_str = "#{num_loans} loan#{'s' if num_loans > 1}"
            @log << "#{entity.name} pays #{@game.format_currency(owed)} interest for #{loans_str}"
            entity.spend(owed, @game.bank, check_cash: false)
          end
        end
      end
    end
  end
end
