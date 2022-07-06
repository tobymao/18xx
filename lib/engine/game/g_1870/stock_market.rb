# frozen_string_literal: true

module Engine
  module Game
    module G1870
      class StockMarket < Engine::StockMarket
        def move_up(corporation)
          r, c = corporation.share_price.coordinates
          return super if r.positive?
          return if c + 1 >= @market[r].size

          move_right(corporation)
          move_down(corporation)
        end

        def right_ledge?(r, c)
          super || (@market.dig(r, c).type != :ignore_one_sale && @market.dig(r, c + 1)&.type == :ignore_one_sale)
        end
      end
    end
  end
end
