# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Icons < Base
        needs :show_destinations, default: true, store: true
        include SmallItem

        ICON_RADIUS = 16
        DELTA_X = (ICON_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :pointy && num_rendered_icons == 1
            POINTY_SMALL_ITEM_LOCATIONS
          elsif layout == :pointy
            POINTY_WIDE_ITEM_LOCATIONS
          elsif layout == :flat && num_rendered_icons == 1
            SMALL_ITEM_LOCATIONS
          else
            WIDE_ITEM_LOCATIONS
          end
        end

        def num_rendered_icons
          @icons.count { |i| @show_destinations || !i.destination? }
        end

        def load_from_tile
          @icons = @tile.icons
          @num_cities = @tile.cities.size
        end

        def destination_icon_patterns
          @icons.map.with_index do |icon, index|
            next unless icon.destination?

            h(:pattern,
              {
                attrs: {
                  id: "#{@tile.id}_#{index}",
                  width: (2 * ICON_RADIUS).to_s,
                  height: (2 * ICON_RADIUS).to_s,
                },
              },
              [
                h(
                  :image,
                  attrs: {
                    href: icon.image,
                    width: (2 * ICON_RADIUS).to_s,
                    height: (2 * ICON_RADIUS).to_s,
                  }
                ),
              ])
          end.compact
        end

        def render_part
          children = []
          children << h(:defs, destination_icon_patterns) if @show_destinations

          icon_images = @icons.select { |i| @show_destinations || !i.destination? }.map.with_index do |icon, index|
            if icon.destination?
              h(:circle,
                attrs: {
                  fill: "url(##{@tile.id}_#{index})",  # icon.image,
                  cx: "#{ICON_RADIUS + ((index - (num_rendered_icons - 1) / 2.0) * -DELTA_X).round(2)}px",
                  cy: "#{ICON_RADIUS}px",
                  r: "#{ICON_RADIUS}px",
                })
            else
              h(:image,
                attrs: {
                  href: icon.image,
                  x: ((index - (num_rendered_icons - 1) / 2.0) * -DELTA_X).round(2),
                  width: "#{ICON_RADIUS * 2}px",
                  height: "#{ICON_RADIUS * 2}px",
                })
            end
          end

          children << h(:g,
                        { attrs: { transform: "#{rotation_for_layout} translate(#{-ICON_RADIUS} #{-ICON_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, icon_images),
          ])

          h(:g, children)
        end
      end
    end
  end
end
