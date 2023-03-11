# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G1866
      class StockMarket < Engine::StockMarket
        def down(_corporation, coordinates)
          r, c = coordinates

          if r == 2
            c -= 1 if c.positive?
          else
            r += 1
          end

          share_price([r, c]) ? [r, c] : coordinates
        end

        def up(_corporation, coordinates)
          r, c = coordinates

          if r.positive?
            r -= 1
          else
            r += 1
            c += 1
          end

          share_price([r, c]) ? [r, c] : coordinates
        end
      end
    end
  end
end
