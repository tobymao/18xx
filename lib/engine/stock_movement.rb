# frozen_string_literal: true

module Engine
  class BaseMovement
    def initialize(market)
      @market = market
    end

    def share_price(coordinates)
      row, column = coordinates
      @market[row]&.[](column)
    end

    def left(coordinates)
      raise NotImplementedError
    end

    def right(coordinates)
      raise NotImplementedError
    end

    def down(coordinates)
      raise NotImplementedError
    end

    def up(coordinates)
      raise NotImplementedError
    end
  end

  class TwoDimensionalMovement < BaseMovement
    def left(coordinates)
      r, c = coordinates
      if c.positive? && share_price([r, c - 1])
        [r, c - 1]
      else
        down(coordinates)
      end
    end

    def right(coordinates)
      r, c = coordinates
      if c + 1 >= @market[r].size
        up(coordinates)
      else
        [r, c + 1]
      end
    end

    def down(coordinates)
      r, c = coordinates
      r += 1 if r + 1 < @market.size
      [r, c]
    end

    def up(coordinates)
      r, c = coordinates
      r -= 1 if r - 1 >= 0
      [r, c]
    end
  end

  class OneDimensionalMovement < BaseMovement
    def left(coordinates)
      r, c = coordinates
      c -= 1 if c - 1 >= 0
      [r, c]
    end

    def right(coordinates)
      r, c = coordinates
      c += 1 if c + 1 < @market[r].size
      [r, c]
    end

    def down(coordinates)
      left(coordinates)
    end

    def up(coordinates)
      right(coordinates)
    end
  end

  class ZigZagMovement < BaseMovement
    def left(coordinates)
      r, c = coordinates
      c -= 2 if c - 2 >= 0
      [r, c]
    end

    def right(coordinates)
      r, c = coordinates
      c += 2 if c + 2 < @market[r].size
      [r, c]
    end

    def down(coordinates)
      r, c = coordinates
      c -= 1 if c.positive?
      [r, c]
    end

    def up(coordinates)
      r, c = coordinates
      c += 1 if c + 1 < @market[r].size
      [r, c]
    end
  end
end
