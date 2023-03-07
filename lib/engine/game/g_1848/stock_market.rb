# frozen_string_literal: true

require_relative '../../stock_market'
require_relative 'game'

module Engine
  module Game
    module G1848
      class StockMarket < Engine::StockMarket
        def down(_corporation, coordinates)
          r, c = coordinates
          r += 1 if r + 1 < @market.size && r + 1 != G1848::Game::BOE_ROW && share_price([r + 1, c])
          [r, c]
        end
      end
    end
  end
end
