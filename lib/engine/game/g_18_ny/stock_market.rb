# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18NY
      class StockMarket < Engine::StockMarket
        def move_up(corporation)
          if top_row?(corporation)
            move_right(corporation)
            move_down(corporation)
            return
          end

          super
        end

        def top_row?(corporation)
          corporation.share_price.coordinates.first.zero?
        end
      end
    end
  end
end
