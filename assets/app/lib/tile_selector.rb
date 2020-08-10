# frozen_string_literal: true

module Lib
  class TileSelector
    attr_reader :entity, :hex, :tile, :x, :y, :role

    def initialize(hex, tile, coordinates, root, entity, role)
      @hex = hex
      @tile = tile
      @x, @y = coordinates
      @root = root
      @entity = entity
      @role = role
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
