# frozen_string_literal: true

require 'view/tiles'

module View
  module Game
    class TileManifest < Tiles
      needs :game
      needs :tile_selector, default: nil, store: true

      def render_tile_selector(remaining, tile, shift: 0)
        return [] unless @tile_selector
        return [] if @tile_selector.role != :tile_page || @tile_selector.hex&.tile&.name != tile.name

        upgrade_tiles = @game.all_potential_upgrades(@tile_selector.hex.tile, tile_manifest: true).map do |t|
          [t, remaining[t.name]&.any? ? nil : 'None Left']
        end

        # Move the position to the middle of the hex
        props = {
         style: {
           position: 'absolute',
           left: "#{WIDTH * shift + WIDTH / 2}px",
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

        if @game.tile_groups.empty?
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
        else
          all_tiles = @game.all_tiles.sort.group_by(&:name)
          children = @game.tile_groups.flat_map do |group|
            if group.one?
              name = group.first
              num = remaining[name]&.size || 0
              unavailable = num.positive? ? nil : 'None Left'
              tile = all_tiles[name].first

              render_tile_blocks(name,
                                 tile: tile,
                                 num: num,
                                 unavailable: unavailable,
                                 layout: @game.layout,
                                 clickable: true,
                                 extra_children: render_tile_selector(remaining, tile))
            else
              name_a, name_b = group
              num = remaining[name_a]&.size || 0

              unavailable = num.positive? ? nil : 'None Left'

              tile_a = all_tiles[name_a].first
              tile_b = all_tiles[name_b].first

              render_tile_sides(name_a,
                                name_b,
                                tile_a: tile_a,
                                tile_b: tile_b,
                                num: num,
                                unavailable: unavailable,
                                layout: @game.layout,
                                clickable: true,
                                extra_children_a: render_tile_selector(remaining, tile_a),
                                extra_children_b: render_tile_selector(remaining, tile_b, shift: 1))

            end
          end
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
