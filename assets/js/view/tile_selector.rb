# frozen_string_literal: true

require 'view/hex'

require 'engine/hex'
require 'engine/tile'

module View
  class TileSelector < Snabberb::Component
    needs :selected_hex_info, store: true

    def render
      style = {
        border: 'solid 1px rgba(0,0,0,0.2)',
        position: 'absolute',
        left: @selected_hex_info[:x] + Hex::SIZE,
        top: @selected_hex_info[:y],
        opacity: 0.5,
      }

      hexes = [
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('7')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('B2', layout: 'flat', tile: Engine::Tile.for('8')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A3', layout: 'flat', tile: Engine::Tile.for('9')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('B4', layout: 'flat', tile: Engine::Tile.for('5')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('C1', layout: 'flat', tile: Engine::Tile.for('6')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('C3', layout: 'flat', tile: Engine::Tile.for('57')), role: :tile_selector),
      ]

      h(:div, { style: style }, [
        h(:svg, { style: { width: '250px', height: '225px' } }, [
          h(:g, { attrs: { transform: 'scale(0.5)' } }, hexes)
        ]),
      ])
    end
  end
end
