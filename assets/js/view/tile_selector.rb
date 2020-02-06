# frozen_string_literal: true

require 'view/hex'

require 'engine/hex'
require 'engine/tile'

module View
  class TileSelector < Snabberb::Component
    needs :tile_selector, store: true
    needs :tiles

    def render
      hexes = @tiles.map do |tile|
        hex = Engine::Hex.new('A1', layout: 'flat', tile: tile)
        h(Hex, hex: hex, role: :tile_selector)
      end

      theta = 360.0 / hexes.size * Math::PI / 180

      hexes = hexes.map.with_index do |hex, index|
        style = {
          position: 'absolute',
          left: Hex::SIZE * Math.cos(index * theta) + 70,
          bottom: Hex::SIZE * Math.sin(index * theta) + 80,
          width: 60,
          height: 60,
          'pointer-events' => 'auto',
        }
        h(:svg, { style: style }, [h(:g, { attrs: { transform: 'scale(0.3)' } }, [hex])])
      end

      style = {
        position: 'absolute',
        left: @tile_selector.x - 50,
        top: @tile_selector.y - 50,
        width: '200px',
        height: '200px',
        'pointer-events' => 'none',
      }

      h(:div, { style: style }, hexes)
    end
  end
end
