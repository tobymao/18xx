# frozen_string_literal: true

module Engine
  module Game
    module G1822Africa
      class StockMarket < Engine::StockMarket
        def right(corporation, coordinates)
          if corporation&.type == :minor && corporation&.share_price&.types&.include?(:max_price)
            coordinates
          else
            super
          end
        end
      end
    end
  end
end
