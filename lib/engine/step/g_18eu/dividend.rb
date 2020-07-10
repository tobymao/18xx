# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G18EU
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout withhold half].freeze
        include HalfPay
        include MinorHalfPay

        def change_share_price(entity, revenue = 0)
          return if entity.minor?

          price = entity.share_price.price
          @stock_market.move_left(entity) if revenue.zero?
          @stock_market.move_right(entity) if revenue >= price
          log_share_price(entity, price)
        end
      end
    end
  end
end
