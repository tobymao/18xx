# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Icons < Base
        include SmallItem

        P_WIDE_TOP_CORNER = {
          region_weights: [0, 1, 2, 3, 4],
          x: 0,
          y: -65,
        }.freeze

        P_WIDE_BOTTOM_CORNER = {
          region_weights: [19, 20, 21, 22, 23],
          x: 0,
          y: 65,
        }.freeze

        PP_WIDE_TOP_CORNER = {
          region_weights: [0, 1, 2, 3, 5, 6],
          x: 0,
          y: -65,
        }.freeze

        PP_WIDE_BOTTOM_CORNER = {
          region_weights: [17, 18, 20, 21, 22, 23],
          x: 0,
          y: 65,
        }.freeze

        WIDE_ITEM_LOCATIONS = [PP_WIDE_TOP_CORNER,
                               PP_WIDE_BOTTOM_CORNER].freeze

        POINTY_WIDE_ITEM_LOCATIONS = [PP_WIDE_TOP_CORNER,
                                      PP_WIDE_BOTTOM_CORNER].freeze

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

        def render_part
          children = @icons.map.with_index do |icon, index|
            h(:image,
              attrs: {
                href: icon.image,
                x: ((index - (@icons.size - 1) / 2.0) * -DELTA_X).round(2),
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
