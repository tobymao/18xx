# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class Icons < Base
        ICON_RADIUS = 16
        DELTA_X = (ICON_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :pointy
            if @num_cities > 1
              [{
                 region_weights: { BOTTOM_RIGHT_CORNER => 1 },
                 x: (DELTA_X / 2) * (@icons.size - 1),
                 y: 79.5,
               }]
            else
              [{
                 region_weights: { BOTTOM_RIGHT_CORNER => 1 },
                 x: (DELTA_X / 2) * (@icons.size - 1),
                 y: 70.5,
               }]
            end
          elsif layout == :flat
            [{
               region_weights: { RIGHT_CORNER => 1 },
               x: 68,
               y: 0,
             }]
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
