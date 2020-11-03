# frozen_string_literal: true

require_relative 'stock_market'

module Engine
  module G1828
    class StockMarket < StockMarket
      def initialize(market, unlimited_types, multiple_buy_types: [])
        super
        @disabled_par_prices = @par_prices
        @par_prices = []
      end

      def enable_par_price(price)
        return unless (par = @disabled_par_prices.find { |p| p.price == price })

        @par_prices << par
        @disabled_par_prices.delete(par)
      end

      def move_up(corporation)
        return move_right(corporation) if top_row?(corporation)

        super
      end

      def top_row?(corporation)
        corporation.share_price.coordinates.first.zero?
      end
    end
  end
end
