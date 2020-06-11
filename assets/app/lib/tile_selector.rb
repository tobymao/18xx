# frozen_string_literal: true

module Lib
  class TileSelector
    attr_reader :entity, :hex, :tile, :x, :y

    def initialize(hex, tile, coordinates, root, entity)
      @hex = hex
      @tile = tile
      @x, @y = coordinates
      @root = root
      @entity = entity
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
