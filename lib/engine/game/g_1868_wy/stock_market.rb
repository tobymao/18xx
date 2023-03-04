# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G1868WY
      class StockMarket < Engine::StockMarket
        def move_up(corporation)
          r, c = corporation.share_price.coordinates

          if r.positive? && share_price([r - 1, c])
            r -= 1
          else
            r += 1
            c += 1
          end
          move(corporation, [r, c])
        end
      end
    end
  end
end
