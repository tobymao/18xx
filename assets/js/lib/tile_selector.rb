# frozen_string_literal: true

module Lib
  class TileSelector
    attr_reader :hex, :x, :y
    attr_accessor :tile

    def initialize(hex, tile, event, root)
      @hex = hex
      @tile = tile
      @x, @y = get_coordinates(event)
      @root = root
    end

    def get_coordinates(event)
      rect = event.JS['currentTarget'].JS.getBoundingClientRect
      [rect.JS['x'], rect.JS['y']]
    end

    def tile=(new_tile)
      @tile = new_tile
      @root.update
    end

    def rotate!
      @tile.rotate!
      @root.update
    end
  end
end
