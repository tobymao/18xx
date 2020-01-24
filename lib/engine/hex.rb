# frozen_string_literal: true

module Engine
  class Hex
    attr_reader :coordinates, :layout, :tile, :x, :y

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

    def ==(other)
      @coordinates == other.coordinates
    end
  end
end
