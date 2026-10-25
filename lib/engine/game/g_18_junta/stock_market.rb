# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18Junta
      # Rules summary 3.5: when a marker must move up while on the top row, it moves one space
      # right instead (the last space of the row stays where it is).
      class StockMarket < Engine::StockMarket
        def up(corporation, coordinates)
          return super unless top_row?(coordinates)
          return coordinates if max_share_price?(coordinates)

          [coordinates[0], coordinates[1] + 1]
        end
      end
    end
  end
end
