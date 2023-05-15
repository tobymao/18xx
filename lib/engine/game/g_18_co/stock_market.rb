# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18CO
      class StockMarket < Engine::StockMarket
        # In 18CO, stock that hit the top move right
        def up(corporation, coordinates)
          r, c = coordinates

          if r - 1 >= 0 && share_price([r - 1, c])
            [r - 1, c]
          elsif share_price([r, c + 1])
            right(corporation, coordinates)
          else
            [r, c]
          end
        end
      end
    end
  end
end
