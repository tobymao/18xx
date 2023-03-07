# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18NY
      class StockMarket < Engine::StockMarket
        def up(corporation, coordinates)
          return super unless top_row?(corporation)
          return coordinates if max_share_price?(corporation)

          coordinates = right(corporation, coordinates)
          down(corporation, coordinates)
        end

        def top_row?(corporation)
          corporation.share_price.coordinates.first.zero?
        end

        def max_share_price?(corporation)
          corporation.share_price == @market[0][-1]
        end
      end
    end
  end
end
