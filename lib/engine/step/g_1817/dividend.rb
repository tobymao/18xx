# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'

module Engine
  module Step
    module G1817
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        PENULTIMATE_PRICE = 540
        FINAL_PRICE = 600
        include HalfPay

        def half_pay_withhold_amount(entity, revenue)
          entity.total_shares == 2 ? revenue / 2.0 : super
        end

        def share_price_change(entity, revenue = 0)
          price = entity.share_price.price
          price = 40 if entity.share_price.acquisition?

          return { share_direction: :left, share_times: 1 } unless revenue.positive?

          times = 0
          times = 1 if revenue >= price && price < FINAL_PRICE
          times = 2 if revenue >= price * 2 && price < PENULTIMATE_PRICE
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
