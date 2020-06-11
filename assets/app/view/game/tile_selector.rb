# frozen_string_literal: true

require 'view/game/hex'

module View
  module Game
    class TileSelector < Snabberb::Component
      needs :tile_selector, store: true
      needs :layout
      needs :tiles
      SCALE = 0.3
      SIZE = Hex::SIZE * SCALE

      def render
        hexes = @tiles.map do |tile|
          hex = Engine::Hex.new('A1', layout: @layout, tile: tile)
          h(Hex, hex: hex, role: :tile_selector)
        end

        theta = 360.0 / hexes.size * Math::PI / 180

        hexes = hexes.map.with_index do |hex, index|
          style = {
            position: 'absolute',
            left: "#{Hex::SIZE * Math.cos(index * theta) - SIZE}px",
            bottom: "#{Hex::SIZE * Math.sin(index * theta) - SIZE}px",
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
