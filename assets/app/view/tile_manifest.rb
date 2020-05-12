# frozen_string_literal: true

require 'view/tiles'

module View
  class TileManifest < Tiles
    needs :tiles
    needs :all_tiles

    def render
      remaining = @tiles.group_by(&:name)

      children = @all_tiles.sort.group_by(&:name).map do |name, tiles|
        num = remaining[name]&.size || 0
        opacity = num.positive? ? 1.0 : 0.5
        render_tile_block(name, tile: tiles.first, num: num, opacity: opacity)
      end

      h('div#tile_manifest', children)
    end
  end
end
