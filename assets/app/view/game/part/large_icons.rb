# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'
require 'lib/settings'

module View
  module Game
    module Part
      class LargeIcons < Base
        include Lib::Settings
        include LargeItem

        needs :game, default: nil, store: true

        LARGE_RADIUS = 25
        DELTA_X = (LARGE_RADIUS * 2) + 2

        def load_from_tile
          # multiple large icons not supported
          @icons = @tile.icons.select(&:large)
        end

        def render_part
          children = @icons.map.with_index do |icon, index|
            # large icons can have player colors or shape decorations
            radius = LARGE_RADIUS
            adjust = 0

            dx = (((index - ((@icons.size - 1) / 2.0)) * -DELTA_X) + LARGE_RADIUS).round(2)
            dy = LARGE_RADIUS.round(2)
            decor = h(:circle, attrs: { r: LARGE_RADIUS, fill: 'white', cx: dx, cy: dy })

            show_player_colors = setting_for(:show_player_colors, @game)
            if (decoration = @game&.decorate_marker(icon))
              color = decoration[:color]
              case decoration[:shape]
              when :circle
                radius -= 4
                adjust = 4
                decor = h(:circle, attrs: { r: LARGE_RADIUS, fill: color, cx: dx, cy: dy })
              when :diamond
                radius -= 4
                adjust = 4
                size = LARGE_RADIUS - 4
                decor = h(:polygon, attrs: { points: diamond_points(size, dx, dy), fill: color })
              else # hexagon
                radius -= 2
                adjust = 2
                decor = h(:polygon, attrs: { points: hex_points(LARGE_RADIUS, dx, dy), fill: color })
              end
            elsif show_player_colors && (owner = icon&.owner) && @game.players.include?(owner)
              color = player_colors(@game.players)[owner]
              radius -= 4
              adjust = 4
              decor = h(:circle, attrs: { r: LARGE_RADIUS, fill: color, cx: dx, cy: dy })
            end

            icon_x_pos = (((index - ((@icons.size - 1) / 2.0)) * -DELTA_X) + adjust).round(2)
            icon_y_pos = adjust.round(2)

            h(:g, [
              decor,
              h(:image,
                attrs: {
                  href: icon.image,
                  x: icon_x_pos,
                  y: icon_y_pos,
                  width: "#{radius * 2}px",
                  height: "#{radius * 2}px",
                }),
            ].compact)
          end

          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-LARGE_RADIUS} #{-LARGE_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
        end
      end
    end
  end
end
