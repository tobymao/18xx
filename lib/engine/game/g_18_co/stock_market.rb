# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18CO
      class StockMarket < Engine::StockMarket
        # In 18CO, stock that hit the top move right
        def move_up(corporation)
          r, c = corporation.share_price.coordinates

          if r - 1 >= 0 && share_price([r - 1, c])
            r -= 1
            move(corporation, [r, c])
          elsif share_price([r, c + 1])
            move_right(corporation)
          end
        end
      end
    end
  end
end
