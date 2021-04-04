# frozen_string_literal: true

require_relative 'stock_market'

module Engine
  module Game
    module G1870
      class StockMarket < Engine::StockMarket
        def move_right(corporation)
          r, c = corporation.share_price.coordinates

          if corporation.share_price.type != :ignore_one_sale && @market.dig(r, c + 1)&.type == :ignore_one_sale
            return move_up(corporation)
          end

          super
        end
      end
    end
  end
end
