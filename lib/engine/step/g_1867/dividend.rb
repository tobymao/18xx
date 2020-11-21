# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G1867
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay
        include MinorHalfPay

        def share_price_change(entity, revenue = 0)
          if entity.minor?
            super
          else

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            if revenue >= price
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          end
        end
      end
    end
  end
end
