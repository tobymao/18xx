# frozen_string_literal: true

module Engine
  module Game
    module G1844
      class StockMarket < Engine::StockMarket
        def regional_max_price?(coordinates)
          row, col = coordinates
          return true if @market[row][col]&.type != :type_limited && @market[row][col + 1]&.type == :type_limited
        end

        def right_ledge?(coordinates)
          regional_max_price?(coordinates) ? true : super
        end

        def right(corporation, coordinates)
          return up(corporation, coordinates) if corporation&.type == :regional && regional_max_price?(coordinates)

          super
        end
      end
    end
  end
end
