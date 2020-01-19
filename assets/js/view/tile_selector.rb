# frozen_string_literal: true

require 'view/hex'

require 'engine/hex'
require 'engine/tile'

module View
  class TileSelector < Snabberb::Component
    needs :hex

    def render
      style = {
        border: 'solid 1px rgba(0,0,0,0.2)',
        position: 'absolute',
        left: @hex[:abs_x],
        top: @hex[:abs_y],
      }

      hexes = [
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('8')), location: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A3', layout: 'flat', tile: Engine::Tile.for('9')), location: :tile_selector),
      ]

      h(:div, { style: style }, [
        h(:svg, { style: { width: '300px', height: '300px' } }, [
          h(:g, { attrs: { transform: 'scale(0.5)' } }, hexes)
        ]),
      ])
    end
  end
end
