# frozen_string_literal: true

module Engine
  module Game
    module G1867
      # 1867 & 1861
      class StockMarket < Engine::StockMarket
        def move_up(corporation)
          return move_right(corporation) if one_d?

          r, c = corporation.share_price.coordinates
          if r - 1 >= 0
            r -= 1
          elsif corporation.type == :major
            # 1861: If hits the ceiling moves right and down 1 (not changing the share price), but only for majors
            r += 1
            c += 1
          end
          move(corporation, [r, c])
        end

        def move_right(corporation)
          if corporation.type == :minor && corporation.share_price.types.include?(:max_price)
            move_up(corporation) unless one_d?
          else
            super
          end
        end
      end
    end
  end
end
