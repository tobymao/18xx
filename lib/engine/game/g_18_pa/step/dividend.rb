# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18PA
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          def payout(entity, revenue)
            return super if entity.corporation? && entity.type != :minor

            amount = revenue / 2
            { corporation: 0, per_share: amount }
          end

          def share_price_change(entity, revenue = 0)
            return {} if entity.type == :minor

            super
          end
        end
      end
    end
  end
end
