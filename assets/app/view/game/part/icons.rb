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
          if layout == :pointy
            delta_y =
              if @num_cities > 1
                79.5
              else
                70.5
              end

            [{
               region_weights: { BOTTOM_RIGHT_CORNER => 1 },
               x: (DELTA_X / 2) * (@icons.size - 1),
               y: delta_y,
             }]

          elsif layout == :flat
            SMALL_ITEM_LOCATIONS
          end
        end

        def load_from_tile
          @icons = @tile.icons
          @num_cities = @tile.cities.size
        end

        def render_part
          children = @icons.map.with_index do |icon, index|
            h(:image,
              attrs: {
                href: icon.image,
                x: index * -DELTA_X,
                width: "#{ICON_RADIUS * 2}px",
                height: "#{ICON_RADIUS * 2}px",
              })
          end

          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-ICON_RADIUS} #{-ICON_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
        end
      end
    end
  end
end
