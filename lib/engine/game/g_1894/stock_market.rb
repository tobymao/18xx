# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G1894
      class StockMarket < Engine::StockMarket
        def move_up(corporation)
          return move_right(corporation) if top_row?(corporation)

          super
        end

        def top_row?(corporation)
          corporation.share_price.coordinates.first.zero?
        end
      end
    end
  end
end