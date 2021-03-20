# frozen_string_literal: true

require 'view/game/part/base'
require 'lib/settings'

module View
  module Game
    module Part
      class LargeIcons < Base
        include Lib::Settings

        needs :game, default: nil, store: true

        P_WIDE_LEFT_CORNER = {
          region_weights: [5, 6, 7, 12, 13, 14],
          x: -60,
          y: 0,
        }.freeze

        P_WIDE_UPPER_LEFT_CORNER = {
          region_weights: [0, 1, 2, 6, 7, 8],
          x: -30,
          y: -52,
        }.freeze

        P_WIDE_BOTTOM_LEFT_CORNER = {
          region_weights: [13, 14, 15, 19, 20, 21],
          x: -30,
          y: 52,
        }.freeze

        P_WIDE_RIGHT_CORNER = {
          region_weights: [9, 10, 11, 16, 17, 18],
          x: 60,
          y: 0,
        }.freeze

        P_WIDE_UPPER_RIGHT_CORNER = {
          region_weights: [2, 3, 4, 8, 9, 10],
          x: 30,
          y: -52,
        }.freeze

        P_WIDE_BOTTOM_RIGHT_CORNER = {
          region_weights: [15, 16, 17, 21, 22, 23],
          x: 30,
          y: 52,
        }.freeze

        PP_WIDE_LEFT_CORNER = {
          region_weights: [5, 6, 7, 12, 13, 14],
          x: -52,
          y: -30,
        }.freeze

        PP_WIDE_UPPER_LEFT_CORNER = {
          region_weights: [0, 1, 2, 6, 7, 8],
          x: 0,
          y: -60,
        }.freeze

        PP_WIDE_BOTTOM_LEFT_CORNER = {
          region_weights: [13, 14, 15, 19, 20, 21],
          x: -52,
          y: 30,
        }.freeze

        PP_WIDE_RIGHT_CORNER = {
          region_weights: [9, 10, 11, 16, 17, 18],
          x: 52,
          y: 30,
        }.freeze

        PP_WIDE_UPPER_RIGHT_CORNER = {
          region_weights: [2, 3, 4, 8, 9, 10],
          x: 52,
          y: -30,
        }.freeze

        PP_WIDE_BOTTOM_RIGHT_CORNER = {
          region_weights: [15, 16, 17, 21, 22, 23],
          x: 0,
          y: 60,
        }.freeze

        LARGE_ITEM_LOCATIONS = [P_WIDE_LEFT_CORNER,
                                P_WIDE_UPPER_LEFT_CORNER,
                                P_WIDE_BOTTOM_LEFT_CORNER,
                                P_WIDE_RIGHT_CORNER,
                                P_WIDE_UPPER_RIGHT_CORNER,
                                P_WIDE_BOTTOM_RIGHT_CORNER].freeze

        POINTY_LARGE_ITEM_LOCATIONS = [PP_WIDE_LEFT_CORNER,
                                       PP_WIDE_UPPER_LEFT_CORNER,
                                       PP_WIDE_BOTTOM_LEFT_CORNER,
                                       PP_WIDE_RIGHT_CORNER,
                                       PP_WIDE_UPPER_RIGHT_CORNER,
                                       PP_WIDE_BOTTOM_RIGHT_CORNER].freeze

        LARGE_RADIUS = 25
        DELTA_X = (LARGE_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :flat
            LARGE_ITEM_LOCATIONS
          else
            POINTY_LARGE_ITEM_LOCATIONS
          end
        end

        def load_from_tile
          # multiple large icons not supported
          @icons = @tile.icons.select(&:large)
        end

        def render_part
          children = @icons.map.with_index do |icon, index|
            # large icons can have player colors
            color = 'white'
            radius = LARGE_RADIUS
            adjust = 0
            show_player_colors = setting_for(:show_player_colors, @game)
            if show_player_colors && (owner = icon&.owner) && @game.players.include?(owner)
              color = player_colors(@game.players)[owner]
              radius -= 4
              adjust = 4
            end

            icon_x_pos = ((index - (@icons.size - 1) / 2.0) * -DELTA_X + adjust).round(2)
            icon_y_pos = adjust.round(2)
            ring_x_pos = (((index - (@icons.size - 1) / 2.0) * -DELTA_X) + LARGE_RADIUS).round(2)
            ring_y_pos = LARGE_RADIUS.round(2)

            h(:g, [
              h(:circle, attrs: { r: LARGE_RADIUS, fill: color, cx: ring_x_pos, cy: ring_y_pos }),
              h(:image,
                attrs: {
                  href: icon.image,
                  x: icon_x_pos,
                  y: icon_y_pos,
                  width: "#{radius * 2}px",
                  height: "#{radius * 2}px",
                }),
            ])
          end

          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-LARGE_RADIUS} #{-LARGE_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
        end
      end
    end
  end
end
