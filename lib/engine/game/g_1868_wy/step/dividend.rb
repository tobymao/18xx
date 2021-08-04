# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class Dividend < Engine::Step::Dividend
          include G1868WY::SkipCoalAndOil

          def share_price_change(entity, revenue = 0)
            entity.minor? ? {} : super
          end

          def log_run_payout(entity, kind, revenue, action, payout)
            super unless entity.minor?
          end
        end
      end
    end
  end
end
