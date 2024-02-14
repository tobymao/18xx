# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18Neb
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def share_price_change(entity, revenue = 0)
            return { share_direction: :right, share_times: 1 } if revenue >= entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            {}
          end
        end
      end
    end
  end
end
