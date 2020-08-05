# frozen_string_literal: true

require 'view/tiles'

module View
  module Game
    class TileManifest < Tiles
      needs :game
      needs :tile_selector, default: nil, store: true

      def potential_upgrades(tile)
        colors = Array(@game.phase.phases.last[:tiles])
        @game.init_tiles
          .select { |t| colors.include?(t.color) }
          .uniq(&:name)
          .select { |t| tile.upgrades_to?(t) }
          .reject(&:blocks_lay)
      end

      def render
        remaining = @game.tiles.group_by(&:name)

        children = @game.init_tiles.sort.group_by(&:name).flat_map do |name, tiles|
          num = remaining[name]&.size || 0
          opacity = num.positive? ? 1.0 : 0.5
          tile = tiles.first
          extra_children = []
          if @tile_selector&.hex&.tile&.name == tile.name
            upgrade_tiles = potential_upgrades(@tile_selector.hex.tile)

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
                         distance: 70,
                         role: :tile_page)

            parent_props = {
              style: {
                overflow: 'inherit',
                margin: '1rem 0',
                position: 'absolute',
              },
            }

            extra_children << h(:div, parent_props, [h(:div, props, [selector])])
          end
          render_tile_blocks(name,
                             tile: tile,
                             num: num,
                             opacity: opacity,
                             layout: @game.layout,
                             clickable: true,
                             extra_children: extra_children)
        end

        props = {
          style: {
            'margin': '40px',
          },
        }
        h('div#tile_manifest', props, children)
      end
    end
  end
end
