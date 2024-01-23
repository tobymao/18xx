# frozen_string_literal: true

module Engine
  module Game
    module G1854
      class StockMarket < Engine::StockMarket
        def move(corp, coordinates, force: false)
          super
          row, col = coordinates
          if !corp.shares_split? && @market[row][col]&.type == :share_split
            corp.split_shares
          end
        end
      end
    end
  end
end
