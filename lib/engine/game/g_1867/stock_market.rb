# frozen_string_literal: true

module Engine
  module Game
    module G1867
      # 1867 & 1861
      class StockMarket < Engine::StockMarket
        def up(corporation, coordinates)
          return right(corporation, coordinates) if one_d?

          r, c = coordinates
          if r - 1 >= 0
            r -= 1
          elsif corporation&.type == :major
            # 1861: If hits the ceiling moves right and down 1 (not changing the share price), but only for majors
            r += 1
            c += 1
          end

          [r, c]
        end

        def right(corporation, coordinates)
          if corporation&.type == :minor && corporation&.share_price&.types&.include?(:max_price)
            if one_d?
              coordinates
            else
              up(corporation, coordinates)
            end
          else
            super
          end
        end
      end
    end
  end
end
