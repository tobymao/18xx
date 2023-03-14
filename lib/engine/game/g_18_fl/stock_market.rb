# frozen_string_literal: true

module Engine
  module Game
    module G18FL
      class StockMarket < Engine::StockMarket
        def right(corporation, coordinates)
          return super if corporation&.type != :five_share || !corporation&.share_price&.types&.include?(:max_price)

          coordinates
        end
      end
    end
  end
end
