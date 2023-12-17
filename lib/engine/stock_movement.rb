# frozen_string_literal: true

# require 'pry-byebug'

module Engine
  class BaseMovement
    def initialize(market)
      @market = market
    end

    def share_price(coordinates)
      row, column = coordinates
      @market.market[row]&.[](column)
    end

    def left(corporation, coordinates)
      raise NotImplementedError
    end

    def right(corporation, coordinates)
      raise NotImplementedError
    end

    def down(corporation, coordinates)
      raise NotImplementedError
    end

    def up(corporation, coordinates)
      raise NotImplementedError
    end

    def down_left_hex(_corporation, coordinates)
      raise NotImplementedError
    end

    def up_left_hex(_corporation, coordinates)
      raise NotImplementedError
    end

    def down_right_hex(_corporation, coordinates)
      raise NotImplementedError
    end

    def up_right_hex(_corporation, coordinates)
      raise NotImplementedError
    end
  end

  class TwoDimensionalMovement < BaseMovement
    def left(corporation, coordinates)
      r, c = coordinates
      if c.positive? && share_price([r, c - 1])
        [r, c - 1]
      else
        @market.down(corporation, coordinates)
      end
    end

    def right(corporation, coordinates)
      r, c = coordinates
      if c + 1 >= @market.market[r].size
        @market.up(corporation, coordinates)
      else
        [r, c + 1]
      end
    end

    def down(_corporation, coordinates)
      r, c = coordinates
      r += 1 if r + 1 < @market.market.size
      [r, c]
    end

    def up(_corporation, coordinates)
      r, c = coordinates
      r -= 1 if r - 1 >= 0
      [r, c]
    end
  end

  class OneDimensionalMovement < BaseMovement
    def left(_corporation, coordinates)
      r, c = coordinates
      c -= 1 if c - 1 >= 0
      [r, c]
    end

    def right(_corporation, coordinates)
      r, c = coordinates
      c += 1 if c + 1 < @market.market[r].size
      [r, c]
    end

    def down(corporation, coordinates)
      @market.left(corporation, coordinates)
    end

    def up(corporation, coordinates)
      @market.right(corporation, coordinates)
    end
  end

  class HexMovement < BaseMovement
    def left(corporation, coordinates)
      r, c = coordinates
      new_coords = [r, c - 2]
      return new_coords if share_price(new_coords)
      @market.down_left_hex(corporation, coordinates)
    end

    def right(corporation, coordinates)
      r, c = coordinates
      new_coords = [r, c + 2]
      return new_coords if share_price(new_coords)
      @market.up_right_hex(corporation, coordinates)
    end

    def down_left_hex(_corporation, coordinates)
      binding.pry if $binding
      r, c = coordinates
      new_coords = [r + 1, c - 1]
      puts "down_left_hex #{coordinates} #{new_coords}"
      x = share_price(new_coords)
      return new_coords if x
      puts "old coords"
      coordinates
    end

    def up_left_hex(_corporation, coordinates)
      r, c = coordinates
      new_coords = [r - 1, c - 1]
      return new_coords if share_price(new_coords)
      coordinates
    end

    def down_right_hex(_corporation, coordinates)
      r, c = coordinates
      new_coords = [r + 1, c + 1]
      return new_coords if share_price(new_coords)
      coordinates
    end

    def up_right_hex(_corporation, coordinates)
      r, c = coordinates
      new_coords = [r - 1, c + 1]
      return new_coords if share_price(new_coords)
      coordinates
    end
  end

  class ZigZagMovement < BaseMovement
    attr_reader :ledge_movement

    def initialize(market, ledge_movement)
      @market = market
      @ledge_movement = ledge_movement
      super(market)
    end

    def left(_corporation, coordinates)
      r, c = coordinates
      if ledge_movement
        c -= 2
        c = 0 if c.negative?
      elsif c - 2 >= 0
        c -= 2
      end
      [r, c]
    end

    def right(_corporation, coordinates)
      r, c = coordinates
      if ledge_movement
        c += 2
        c = @market.market[r].size - 1 if c >= @market.market[r].size
      elsif c + 2 < @market.market[r].size
        c += 2
      end
      [r, c]
    end

    def down(_corporation, coordinates)
      r, c = coordinates
      c -= 1 if c.positive?
      [r, c]
    end

    def up(_corporation, coordinates)
      r, c = coordinates
      c += 1 if c + 1 < @market.market[r].size
      [r, c]
    end
  end
end
