# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G18EU
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay
        include MinorHalfPay

        def share_price_change(entity, revenue = 0)
          return {} if entity.minor?

          price = entity.share_price.price
          return { share_direction: :left, share_times: 1 } if revenue.zero?
          return { share_direction: :right, share_times: 1 } if revenue >= price

          {}
        end
      end
    end
  end
end
