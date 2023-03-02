# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G1866
      class StockMarket < Engine::StockMarket
        def move_down(corporation)
          r, c = corporation.share_price.coordinates

          if r == 2
            c -= 1 if c.positive?
          else
            r += 1
          end
          move(corporation, [r, c]) if share_price([r, c])
        end

        def move_up(corporation)
          r, c = corporation.share_price.coordinates

          if r.positive?
            r -= 1
          else
            r += 1
            c += 1
          end
          move(corporation, [r, c]) if share_price([r, c])
        end
      end
    end
  end
end
