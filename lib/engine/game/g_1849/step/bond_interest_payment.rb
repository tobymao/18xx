# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
      module Step
        class BondInterestPayment < Engine::Step::Base
          def actions(_entity)
            # Repaying interest is automatic, but this hooks into the skip
            []
          end

          def log_skip(entity)
            super if @game.bonds?
          end

          def log_pass(entity)
            super if @game.bonds?
          end

          def blocks?
            false
          end

          def skip!
            pass!
            entity = current_entity

            return unless (owed = @game.pay_interest!(entity))

            # This case only occurs if the corporation can't pay all the interest.
            # A negative cash value will trigger emergency money raising.
            @log << "#{entity.name} pays #{@game.format_currency(owed)} interest for issued bond"
            entity.spend(owed, @game.bank, check_cash: false)
          end
        end
      end
    end
  end
end
