# frozen_string_literal: true

require_relative '../../../step/half_pay'
require_relative '../../g_1817/step/dividend'

module Engine
  module Game
    module G18USA
      module Step
        class Dividend < G1817::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            price = 40 if entity.share_price.acquisition?

            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            times = 1 if revenue >= (price * 0.5).floor
            times = 2 if revenue >= price * 1
            times = 3 if revenue >= (price * 1.5).floor
            times = 4 if revenue >= price * 2
            if times&.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end
        end
      end
    end
  end
end
