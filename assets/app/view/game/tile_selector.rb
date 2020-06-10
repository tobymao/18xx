# frozen_string_literal: true

require 'view/game/hex'

module View
  module Game
    class TileSelector < Snabberb::Component
      needs :tile_selector, store: true
      needs :layout
      needs :tiles
      SCALE = 0.3

      def render
        hexes = @tiles.map do |tile|
          hex = Engine::Hex.new('A1', layout: @layout, tile: tile)
          h(Hex, hex: hex, role: :tile_selector)
        end

        theta = 360.0 / hexes.size * Math::PI / 180

        size = Hex::SIZE * SCALE
        hexes = hexes.map.with_index do |hex, index|
          style = {
            position: 'absolute',
            left: "#{Hex::SIZE * Math.cos(index * theta) - size}px",
            bottom: "#{Hex::SIZE * Math.sin(index * theta) - size}px",
            width: '60px',
            height: '60px',
            filter: 'drop-shadow(5px 5px 2px #888)',
            'pointer-events' => 'auto',
          }
          h(:svg, { style: style }, [h(:g, { attrs: { transform: "scale(#{SCALE})" } }, [hex])])
        end

        h(:div, hexes)
      end
    end
  end
end
