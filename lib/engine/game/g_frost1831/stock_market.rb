# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module GFrost1831
      class StockMarket < Engine::StockMarket
        # Corporations cannot move down into the faction row
        def down(_corporation, coordinates)
          r, c = coordinates
          r += 1 if r + 1 < @market.size && r + 1 != GFrost1831::Game::FACTION_ROW && share_price([r + 1, c])
          [r, c]
        end
      end
    end
  end
end
