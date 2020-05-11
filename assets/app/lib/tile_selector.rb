# frozen_string_literal: true

module Lib
  class TileSelector
    attr_reader :entity, :hex, :tile, :x, :y

    def initialize(hex, tile, event, root, entity)
      @hex = hex
      @tile = tile
      @x, @y = get_coordinates(event)
      @root = root
      @entity = entity
    end

    def get_coordinates(event)
      rect = event.JS['currentTarget'].JS.getBoundingClientRect
      [`window.pageXOffset` + rect.JS['left'], `window.pageYOffset` + rect.JS['top']]
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
