# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Icons < Base
        include SmallItem

        ICON_RADIUS = 16
        DELTA_X = (ICON_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :pointy && @icons.one?
            POINTY_SMALL_ITEM_LOCATIONS
          elsif layout == :pointy
            POINTY_WIDE_ITEM_LOCATIONS
          elsif layout == :flat && @icons.one?
            SMALL_ITEM_LOCATIONS
          else
            WIDE_ITEM_LOCATIONS
          end
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
                  width: "#{2 * ICON_RADIUS}",
                  height: "#{2 * ICON_RADIUS}"
                }
              },
              [
                h(
                  :image,
                  attrs: {
                    href: icon.image,
                    width: "#{2 * ICON_RADIUS}",
                    height: "#{2 * ICON_RADIUS}",
                  }
                )
              ]
            )
          end.compact
        end

        def render_part
          patterns = destination_icon_patterns
          children = @icons.map.with_index do |icon, index|
            if icon.destination?
              h(:circle,
                attrs: {
                  fill: "url(##{@tile.id}_#{index})",#icon.image,
                  cx: "#{ICON_RADIUS + ((index - (@icons.size - 1) / 2.0) * -DELTA_X).round(2)}px",
                  cy: "#{ICON_RADIUS}px",
                  r: "#{ICON_RADIUS}px"
                })
            else
              h(:image,
                attrs: {
                  href: icon.image,
                  x: ((index - (@icons.size - 1) / 2.0) * -DELTA_X).round(2),
                  width: "#{ICON_RADIUS * 2}px",
                  height: "#{ICON_RADIUS * 2}px",
                })
            end
          end
          h(:g, [
            h(:defs, patterns),
            h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-ICON_RADIUS} #{-ICON_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
          ])
        end
      end
    end
  end
end
