# frozen_string_literal: true

require 'view/tiles'

module View
  module Game
    class TileManifest < Tiles
      needs :game
      needs :tile_selector, default: nil, store: true

      def render_tile_selector(remaining, tile)
        return [] unless @tile_selector
        return [] if @tile_selector.role != :tile_page || @tile_selector.hex&.tile&.name != tile.name

        upgrade_tiles = @game.all_potential_upgrades(@tile_selector.hex.tile).map do |t|
          [t, remaining[t.name]&.any? ? nil : 'None Left']
        end

        # Move the position to the middle of the hex
        props = {
         style: {
           position: 'absolute',
           left: "#{WIDTH / 2}px",
           top: "#{(WIDTH / 2) - 1}px",
         },
        }

        selector = h(TileSelector,
                     layout: @game.layout,
                     tiles: upgrade_tiles,
                     actions: [],
                     unavailable_clickable: true,
                     role: :tile_page)

        parent_props = {
          style: {
            overflow: 'inherit',
            margin: '1rem 0',
            position: 'absolute',
          },
        }

        [h(:div, parent_props, [h(:div, props, [selector])])]
      end

      def render
        remaining = @game.tiles.group_by(&:name)

        children = @game.all_tiles.sort.group_by(&:name).flat_map do |name, tiles|
          num = remaining[name]&.size || 0
          unavailable = num.positive? ? nil : 'None Left'
          tile = tiles.first

          render_tile_blocks(name,
                             tile: tile,
                             num: num,
                             unavailable: unavailable,
                             layout: @game.layout,
                             clickable: true,
                             extra_children: render_tile_selector(remaining, tile))
        end

        props = {
          style: {
            'margin': '70px',
          },
        }
        h('div#tile_manifest', props, children)
      end
    end
  end
end
