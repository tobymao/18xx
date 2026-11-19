# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18OE
      class StockMarket < Engine::StockMarket
        def up(corporation, coordinates)
          r, c = coordinates
          return super unless r.zero?

          share_price([r, c + 1]) ? [r, c + 1] : coordinates
        end
      end
    end
  end
end
