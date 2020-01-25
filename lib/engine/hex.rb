# frozen_string_literal: true

module Engine
  class Hex
    attr_reader :coordinates, :layout, :tile, :x, :y

    DIRECTIONS = {
      flat: {
        [0, -2] => 0,
        [1, -1] => 1,
        [1, 1] => 2,
        [0, 2] => 3,
        [-1, 1] => 4,
        [-1, -1] => 5,
      },
      pointy: {
        [-1, -1] => 0,
        [1, -1] => 1,
        [2, 0] => 2,
        [1, 1] => 3,
        [-1, 1] => 4,
        [-2, 0] => 5,
      },
    }.freeze

    LETTERS = ('A'..'Z').to_a

    # Coordinates are of the form A1..Z99
    # x and y map to the double coordinate system
    # layout is pointy or flat
    def initialize(coordinates, layout: :pointy, tile: nil)
      @coordinates = coordinates
      @layout = layout
      @x = LETTERS.index(@coordinates[0]).to_i
      @y = @coordinates[1..-1].to_i - 1
      @tile = tile
    end

    def name
      @coordinates
    end

    def lay(tile)
      @tile = tile
    end

    def direction(other)
      [other.x - @x, other.y - @y]
    end

    def neighbor?(other)
      DIRECTIONS[@layout].key?(direction(other))
    end

    def connected?(other)
      direction = DIRECTIONS[@layout][direction(other)]

      @tile.exits.include?(direction) &&
        other.tile.exits.include?(inverted(direction))
    end

    def inverted(direction)
      (direction + 3) % 6
    end

    def ==(other)
      @coordinates == other&.coordinates
    end
  end
end
