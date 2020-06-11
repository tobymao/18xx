# frozen_string_literal: true

require 'view/game/hex'
require 'lib/radial_selector'

module View
  module Game
    class TileSelector < Snabberb::Component
      include Lib::RadialSelector
      needs :tile_selector, store: true
      needs :layout
      needs :tiles
      SCALE = 0.3
      TILE_SIZE = 60
      SIZE = Hex::SIZE * SCALE
      DISTANCE = Hex::SIZE

      def render
        hexes = @tiles.map do |tile|
          hex = Engine::Hex.new('A1', layout: @layout, tile: tile)
          h(Hex, hex: hex, role: :tile_selector)
        end

        hexes = list_coordinates(hexes, DISTANCE, SIZE).map do |hex, left, bottom|
          style = {
            position: 'absolute',
            left: "#{left}px",
            bottom: "#{bottom}px",
            width: "#{TILE_SIZE}px",
            height: "#{TILE_SIZE}px",
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
