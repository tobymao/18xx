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
      needs :left_col, default: false
      needs :right_col, default: false
      needs :top_row, default: false
      needs :bottom_row, default: false

      SCALE = 0.3
      TILE_SIZE = 60
      SIZE = Hex::SIZE * SCALE
      DISTANCE = Hex::SIZE
      FULL_CIRCLE = 360
      MAX_TILES_PER_CIRCLE = 12
      MIN_ANGLE = FULL_CIRCLE / MAX_TILES_PER_CIRCLE
      IDEAL_TILES_PER_CIRCLE = 6
      MAX_ANGLE = FULL_CIRCLE / IDEAL_TILES_PER_CIRCLE
      ADDITIONAL_ANGLE = 20 # extend opening angle by x degrees

      def render
        @distance ||= DISTANCE
        @angle, @rotation = calc_angle_rotation(@left_col, @right_col, @top_row, @bottom_row)
        if @angle < FULL_CIRCLE
          @angle += ADDITIONAL_ANGLE # fan out tiles A_A degrees more
          @rotation -= ADDITIONAL_ANGLE / 2
        end
        tiles = @tiles.map do |tile, unavailable|
          hex = Engine::Hex.new('A1', layout: @layout, tile: tile)
          h(Hex,
            hex: hex,
            actions: @actions,
            role: @role,
            clickable: @unavailable_clickable || !unavailable,
            unavailable: unavailable)
        end

        hexes = coordinates_for(tiles).map do |hex, left, bottom|
          h(:svg,
            { style: style(left * @zoom, bottom * @zoom, TILE_SIZE * @zoom) },
            [h(:g, { attrs: { transform: "scale(#{SCALE * @zoom})" } }, [hex])])
        end

        h(:div, hexes)
      end

      def calc_angle_rotation(left, right, top, bottom)
        # calculate angle of tile fan(s)
        angle = case [left, right, top, bottom].count(true)
                when 0 # center
                  rotation = 0
                  FULL_CIRCLE
                when 1 # side
                  180
                else # corner
                  90
                end
        # rotate tile fan(s) in corners and on sides to center of viewport
        rotation ||= if left && !bottom
                       -90
                     elsif !left && top
                       -180
                     elsif right && !top
                       -270
                     else
                       0
                     end

        [angle, rotation]
      end
    end
  end
end
