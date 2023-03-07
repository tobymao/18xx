# frozen_string_literal: true

module Engine
  module Game
    module G1870
      class StockMarket < Engine::StockMarket
        def up(corporation, coordinates)
          r, c = coordinates
          return super if r.positive?
          return coordinates if c + 1 >= @market[r].size

          coordinates = right(corporation, coordinates)
          down(corporation, coordinates)
        end

        def right(corporation, coordinates)
          return up(corporation, coordinates) if right_ledge?(coordinates)

          super
        end

        def right_ledge?(coordinates)
          r, c = coordinates
          super || (@market.dig(r, c).type != :ignore_one_sale && @market.dig(r, c + 1)&.type == :ignore_one_sale)
        end
      end
    end
  end
end
