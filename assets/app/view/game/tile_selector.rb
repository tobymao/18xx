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
      needs :step

      SCALE = 0.3
      TILE_SIZE = 60
      SIZE = Hex::SIZE * SCALE
      DISTANCE = Hex::SIZE

      def render
        hexes = @tiles.map do |tile|
          hex = Engine::Hex.new('A1', layout: @layout, tile: tile)
          h(Hex, hex: hex, step: @step, role: :tile_selector)
        end

        hexes = list_coordinates(hexes, DISTANCE, SIZE).map do |hex, left, bottom|
          h(:svg,
            { style: style(left, bottom, TILE_SIZE) },
            [h(:g, { attrs: { transform: "scale(#{SCALE})" } }, [hex])])
        end

        h(:div, hexes)
      end
    end
  end
end
