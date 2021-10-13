# frozen_string_literal: true

require 'lib/settings'
require 'view/game/hex'

module View
  class Tiles < Snabberb::Component
    include Lib::Settings

    WIDTH = 80
    HEIGHT = 97
    LINE_PROPS = {
      style: {
        height: '0.9rem',
        padding: '0 0.7rem 0 0.2rem',
      },
    }.freeze
    TEXT_PROPS = {
      style: {
        float: 'left',
        fontSize: '70%',
      },
    }.freeze
    COUNT_PROPS = {
      style: {
        float: 'right',
        lineHeight: '0.9rem',
      },
    }.freeze

    def render_tile_blocks(
      name,
      layout: nil,
      num: nil,
      tile: nil,
      location_name: nil,
      scale: 1.0,
      unavailable: nil,
      rotations: nil,
      hex_coordinates: nil,
      clickable: false,
      extra_children: []
    )
      block_props = {
        style: {
          width: "#{WIDTH * scale}px",
          height: "#{HEIGHT * scale}px",
        },
      }

      tile ||= Engine::Tile.for(name)

      loc_name = location_name || tile.location_name if (tile.cities + tile.towns + tile.offboards).any?

      rotations = [0] if tile.preprinted || !rotations

      rotations.map do |rotation|
        tile.rotate!(rotation)

        unless setting_for(@hide_tile_names)
          text = tile.preprinted ? '' : '#'
          text += name
          text += "-#{rotation}" unless rotations == [0]
        end
        count = tile.unlimited ? '∞' : num.to_s

        hex = Engine::Hex.new(hex_coordinates || 'A1',
                              layout: layout,
                              location_name: loc_name,
                              tile: tile)
        hex.x = 0
        hex.y = 0

        h("div#tile_#{name}.tile__block", block_props, [
            *extra_children,
            h(:div, LINE_PROPS, [
              h(:div, TEXT_PROPS, text),
              h(:div, COUNT_PROPS, count),
            ]),
            h(:svg, { style: { width: '100%', height: '100%' } }, [
              h(:g, { attrs: { transform: "scale(#{scale * 0.4})" } }, [
                h(
                  Game::Hex,
                  hex: hex,
                  role: :tile_page,
                  unavailable: unavailable,
                  clickable: clickable,
                ),
              ]),
            ]),
          ])
      end
    end

    def render_tile_sides(
      name_a,
      name_b,
      layout: nil,
      num: nil,
      tile_a: nil,
      tile_b: nil,
      scale: 1.0,
      unavailable: nil,
      clickable: false,
      extra_children_a: [],
      extra_children_b: []
    )
      block_props = {
        style: {
          width: "#{2 * (WIDTH * scale + 2)}px",
          height: "#{HEIGHT * scale}px",
        },
      }

      text = []
      double_sided_tiles = [[name_a, tile_a], [name_b, tile_b]].map do |name, tile|
        tile ||= Engine::Tile.for(name)
        tile.rotate!(0)
        text << "##{name}" unless setting_for(@hide_tile_names)
        hex = Engine::Hex.new('A1', layout: layout, tile: tile)
        hex.x = 0
        hex.y = 0

        h("svg#tile_#{name}", { style: { width: '50%', height: '100%' } }, [
          h(:g, { attrs: { transform: "scale(#{scale * 0.4})" } }, [
            h(
              Game::Hex,
              hex: hex,
              role: :tile_page,
              unavailable: unavailable,
              clickable: clickable,
            ),
          ]),
        ])
      end
      text = text.join(' / ') unless setting_for(@hide_tile_names)
      count = tile_b.unlimited ? '∞' : num.to_s

      h('div.tile__block', block_props, [
          *extra_children_a,
          *extra_children_b,
          h(:div, LINE_PROPS, [
            h(:div, TEXT_PROPS, text),
            h(:div, COUNT_PROPS, count),
          ]),
          *double_sided_tiles,
      ])
    end
  end
end
