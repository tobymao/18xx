# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G1846
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout withhold half].freeze
        include HalfPay
        include MinorHalfPay

        def change_share_price(entity, revenue = 0)
          return if entity.minor?

          price = entity.share_price.price
          @game.stock_market.move_left(entity) if revenue < price / 2
          @game.stock_market.move_right(entity) if revenue >= price
          @game.stock_market.move_right(entity) if revenue >= price * 2
          @game.stock_market.move_right(entity) if revenue >= price * 3 && price >= 165
          @game.log_share_price(entity, price)
        end

        def skip!
          super

          return unless current_entity.receivership?

          return if current_entity.trains.any?

          return if current_entity.share_price.price.zero?

          @log << "#{current_entity.name} is in receivership and does not own a train."
          change_share_price(current_entity, 0)
        end
      end
    end
  end
end
