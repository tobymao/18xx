# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18NY
      class StockMarket < Engine::StockMarket
        def up(corporation, coordinates)
          return super unless top_row?(coordinates)
          return coordinates if max_share_price?(coordinates)

          coordinates = right(corporation, coordinates)
          down(corporation, coordinates)
        end

        def top_row?(coordinates)
          coordinates.first.zero?
        end

        def max_share_price?(coordinates)
          share_price(coordinates) == @market[0][-1]
        end
      end
    end
  end
end
