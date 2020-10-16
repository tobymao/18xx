# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'

module Engine
  module Step
    module G1817
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay

        def half_pay_withhold_amount(entity, revenue)
          entity.total_shares == 2 ? revenue / 2 : super
        end

        def share_price_change(entity, revenue = 0)
          price = entity.share_price.price
          return { share_direction: :left, share_times: 1 } unless revenue.positive?

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
