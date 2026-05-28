# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G2038
      module Round
        class Operating < Engine::Round::Operating
          def setup
            # Pays all private company revenues to their owners (PI, TS, VA, RS, ST, AE).
            # Fast Buck has revenue: 0 so it is skipped by payout_companies; its $15
            # treasury income is handled separately below.
            super
            pay_fast_buck_treasury
          end

          private

          def pay_fast_buck_treasury
            # Fast Buck earns $15 per OR into its own treasury, not to its owner.
            # This fires even if FB's owner also collects other private income.
            fast_buck = @game.minor_by_id('FB')
            return unless fast_buck&.floated?

            @game.bank.spend(15, fast_buck)
            @game.log << "Fast Buck receives #{@game.format_currency(15)} into its treasury"
          end
        end
      end
    end
  end
end
