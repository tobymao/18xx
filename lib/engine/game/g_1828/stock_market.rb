# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G1828
      class StockMarket < Engine::StockMarket
        def up(corporation, coordinates)
          return right(corporation, coordinates) if top_row?(coordinates)

          super
        end

        def top_row?(coordinates)
          r, _c = coordinates
          r.zero?
        end
      end
    end
  end
end
