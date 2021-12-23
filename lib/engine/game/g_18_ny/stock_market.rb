# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18NY
      class StockMarket < Engine::StockMarket
        def move_up(corporation)
          return super unless top_row?(corporation)
          return if max_share_price?(corporation)

          move_right(corporation)
          move_down(corporation)
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
