# frozen_string_literal: true

require_relative 'stock_market'

module Engine
  module Game
    module G1870
      class StockMarket < Engine::StockMarket
        def move_right(corporation)
          r, c = corporation.share_price.coordinates

          return move_up(corporation) if @market.dig(r, c + 1)&.type == :ignore_one_sale

          super
        end
      end
    end
  end
end
