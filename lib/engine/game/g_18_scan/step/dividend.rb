# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18Scan
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          def withhold(entity, revenue)
            return super if entity.corporation? && entity.type != :minor

            { corporation: 0, per_share: @game.class::MINOR_SUBSIDY }
          end

          def log_run_payout(entity, kind, revenue, action, payout)
            return super if (entity.corporation? && entity.type != :minor) || revenue.positive?

            @log << "#{entity.owner.name} receives subsidy of #{@game.format_currency(payout[:per_share])}"
          end
        end
      end
    end
  end
end
