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
      DISTANCE_SCALE = 0.85
      FULL_CIRCLE = 360
      MAX_TILES_PER_CIRCLE = 12
      MIN_ANGLE = FULL_CIRCLE / MAX_TILES_PER_CIRCLE
      IDEAL_TILES_PER_CIRCLE = 6
      MAX_ANGLE = FULL_CIRCLE / IDEAL_TILES_PER_CIRCLE
      ADDITIONAL_ANGLE = 20
      DISTANCE_SCALE_OUTER_FAN = 1.6

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

      def coordinates_for(hexes)
        n_hexes = hexes.size

        if @angle < FULL_CIRCLE && @angle / (n_hexes - 1) < MIN_ANGLE
          # prevent overflow: distribute into 2 fans (inner fan max: 5 in corner / 7 on sides), revise for 13+ upgrades
          cutoff = [@angle / MIN_ANGLE, (n_hexes + 1) / 3].max
          hexes1 = hexes[0..cutoff]
          hexes2 = hexes[cutoff + 1..-1]
          angle = [((hexes2.size * MIN_ANGLE) / 2) + (ADDITIONAL_ANGLE / DISTANCE_SCALE_OUTER_FAN), 105].min
          rotation = @rotation + ((@angle - angle) / 2)

          list_coordinates(hexes1, @distance, SIZE, @angle, @rotation).concat(
            list_coordinates(hexes2, @distance * DISTANCE_SCALE_OUTER_FAN, SIZE, angle, rotation)
          )
        else
          @distance *= DISTANCE_SCALE if n_hexes <= 8
          angle = [(n_hexes - 1) * MAX_ANGLE, @angle].min
          @rotation += (@angle - angle) / 2 if @angle < FULL_CIRCLE # center tile fan + orient to viewport center
          # rotate tile fan to cover seams between adjacent hexes instead of hexes themselves
          @rotation += 30 if @layout == :pointy && @angle == FULL_CIRCLE && @role != :tile_page

          list_coordinates(hexes, @distance, SIZE, angle, @rotation)
        end
      end
    end
  end
end
