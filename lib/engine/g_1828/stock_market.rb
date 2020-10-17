# frozen_string_literal: true

require_relative 'stock_market'

module Engine
  module G1828
    class StockMarket < StockMarket
      def initialize(market, unlimited_colors, multiple_buy_colors: [])
        super
        @disabled_par_prices = @par_prices
        @par_prices = []
      end

      def enable_par_price(price)
        if par = @disabled_par_prices.find {|p| p.price == price}
          @par_prices << par
          @disabled_par_prices.delete(par)
        end
      end
    end
  end
end
