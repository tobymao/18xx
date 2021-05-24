# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18Scan
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout withhold].freeze
          include Engine::Step::MinorHalfPay

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue < price / 2

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2

            if times.positive?
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
