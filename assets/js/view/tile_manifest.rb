# frozen_string_literal: true

require 'engine/tile'

require 'view/tiles'

module View
  class TileManifest < Tiles
    needs :tiles

    def render
      children = @tiles.sort.group_by(&:name).map do |name, tiles|
        render_tile_block(name, num: tiles.size)
      end

      h('div#tile_manifest', children)
    end
  end
end
