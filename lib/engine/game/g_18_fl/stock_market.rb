# frozen_string_literal: true

module Engine
  module Game
    module G18FL
      class StockMarket < Engine::StockMarket
        def move_right(corporation)
          super unless corporation.type == :five_share && corporation.share_price.types.include?(:max_price)
        end
      end
    end
  end
end
