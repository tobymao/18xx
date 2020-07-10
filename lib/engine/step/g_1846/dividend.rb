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

        def actions(entity)
          return [] if entity.minor?
          super

        end

        def skip!
          return super if current_entity.corporation?

          revenue = routes.sum(&:revenue)
          process_dividend(Action::Dividend.new(
            current_entity,
            kind: revenue.positive? ? 'payout' : 'withhold',
          ))
        end

        def change_share_price(entity, revenue = 0)
          return if entity.minor?

          price = entity.share_price.price
          @game.stock_market.move_left(entity) if revenue < price / 2
          @game.stock_market.move_right(entity) if revenue >= price
          @game.stock_market.move_right(entity) if revenue >= price * 2
          @game.stock_market.move_right(entity) if revenue >= price * 3 && price >= 165
          @game.log_share_price(entity, price)
        end
      end
    end
  end
end
