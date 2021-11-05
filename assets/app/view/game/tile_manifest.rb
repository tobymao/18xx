# frozen_string_literal: true

require 'lib/settings'
require 'view/tiles'

module View
  module Game
    class TileManifest < Tiles
      include Lib::Settings

      needs :game
      needs :tile_selector, default: nil, store: true

      def render
        h(:div, [render_tile_manifest, render_toggle_button])
      end

      def render_tile_selector(remaining, tile, shift: 0)
        return [] unless @tile_selector
        return [] if @tile_selector.role != :tile_page || @tile_selector.hex&.tile&.name != tile.name

        upgrade_tiles = @game.all_potential_upgrades(@tile_selector.hex.tile, tile_manifest: true).map do |t|
          Engine::Tile::ALL_EDGES.select do |r|
            break if @tile_selector.hex.tile.paths.all? { |path| t.paths.any? { |p| path <= p } }

            t.rotate!(r)
          end
          [t, remaining[t.name]&.any? ? nil : 'None Left']
        end

        return [] if upgrade_tiles.empty?

        m = Native(`document.getElementById('tile_manifest').getBoundingClientRect()`)
        c = Native(`document.getElementById('tile_' + #{tile.name}).getBoundingClientRect()`)
        ts_ds = [TileSelector::DROP_SHADOW_SIZE - 5, 0].max # ignore up to 5px of drop-shadow (< 2vmin padding of #app)
        left_col = c.left - m.left < WIDTH
        right_col = m.right - c.right < WIDTH + ts_ds
        bottom_row = m.bottom - c.bottom < WIDTH + ts_ds
        top_row = c.top - m.top < WIDTH

        # Move the position to the middle of the hex
        props = {
          style: {
            position: 'absolute',
            left: "#{(WIDTH * shift) + (WIDTH / 2)}px",
            top: "#{(WIDTH / 2) - 1}px",
          },
        }

        selector = h(TileSelector, layout: @game.layout, tiles: upgrade_tiles, unavailable_clickable: true,
                                   role: :tile_page, left_col: left_col, right_col: right_col,
                                   bottom_row: bottom_row, top_row: top_row)

        parent_props = {
          style: {
            overflow: 'inherit',
            margin: '1rem 0',
            position: 'absolute',
          },
        }

        [h(:div, parent_props, [h(:div, props, [selector])])]
      end

      def render_toggle_button
        toggle = lambda do
          toggle_setting(@hide_tile_names)
          update
        end

        props = {
          style: {
            margin: '0 0 0 1vmin',
          },
          on: {
            click: toggle,
          },
        }

        h(:div, [
          h(:'button.small', props, "Tile Names #{setting_for(@hide_tile_names, @game) ? '❌' : '✅'}"),
        ])
      end

      def render_tile_manifest
        remaining = @game.tiles.group_by(&:name)

        if @game.tile_groups.empty?
          children = @game.all_tiles.sort.group_by(&:name).flat_map do |name, tiles|
            num = remaining[name]&.size || 0
            unavailable = num.positive? ? nil : 'None Left'
            tile = tiles.first
            next if tile.hidden

            render_tile_blocks(name,
                               tile: tile,
                               num: num,
                               unavailable: unavailable,
                               layout: @game.layout,
                               clickable: true,
                               extra_children: render_tile_selector(remaining, tile))
          end.compact
        else
          all_tiles = @game.all_tiles.sort.group_by(&:name)
          children = @game.tile_groups.flat_map do |group|
            if group.one?
              name = group.first
              num = remaining[name]&.size || 0
              unavailable = num.positive? ? nil : 'None Left'
              tile = all_tiles[name].first
              next if tile.hidden

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

              next if tile_a.hidden && tile_b.hidden # can't hide one side of tile

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
          end.compact
        end

        props = {
          style: {
            margin: '3vmin 1vmin',
          },
        }

        h('div#tile_manifest', props, children)
      end
    end
  end
end
