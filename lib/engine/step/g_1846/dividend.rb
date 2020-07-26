# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G1846
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay
        include MinorHalfPay

        def share_price_change(entity, revenue = 0)
          return {} if entity.minor?

          price = entity.share_price.price
          return { share_direction: :left, share_times: 1 } if revenue < price / 2

          times = 0
          times = 1 if revenue >= price
          times = 2 if revenue >= price * 2
          times = 3 if revenue >= price * 3 && price >= 165
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
