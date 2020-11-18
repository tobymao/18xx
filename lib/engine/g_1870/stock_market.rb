# frozen_string_literal: true

require_relative 'stock_market'

module Engine
  module G1870
    class StockMarket < StockMarket
      def move_right(corporation)
        r, c = corporation.share_price.coordinates

        return move_up(corporation) if @market.dig(r, c + 1).type == :ignore_one_sale

        super
      end
    end
  end
end
