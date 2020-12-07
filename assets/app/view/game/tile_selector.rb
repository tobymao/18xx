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
      needs :actions, default: []
      needs :distance, default: nil
      needs :role, default: :tile_selector
      needs :unavailable_clickable, default: false
      needs :zoom, default: 1

      SCALE = 0.3
      TILE_SIZE = 60
      SIZE = Hex::SIZE * SCALE
      DISTANCE = Hex::SIZE

      def render
        @distance ||= DISTANCE
        hexes = @tiles.map do |tile, unavailable|
          hex = Engine::Hex.new('A1', layout: @layout, tile: tile)
          h(Hex,
            hex: hex,
            actions: @actions,
            role: @role,
            clickable: @unavailable_clickable || !unavailable,
            unavailable: unavailable)
        end

        hexes = list_coordinates(hexes, @distance, SIZE).map do |hex, left, bottom|
          h(:svg,
            { style: style(left * @zoom, bottom * @zoom, TILE_SIZE * @zoom) },
            [h(:g, { attrs: { transform: "scale(#{SCALE * @zoom})" } }, [hex])])
        end

        h(:div, hexes)
      end
    end
  end
end
