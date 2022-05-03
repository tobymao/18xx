# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/large_item'
require 'lib/hex'
require 'lib/settings'

module View
  module Game
    module Part
      class FutureLabel < Base
        include Lib::Settings
        include LargeItem

        LARGE_RADIUS = 18
        DELTA_X = (LARGE_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :flat
            LARGE_ITEM_LOCATIONS
          else
            POINTY_LARGE_ITEM_LOCATIONS
          end
        end

        def load_from_tile
          # multiple future labels, or future labels + large icons not supported
          @future_label = @tile.future_label
        end

        def render_part
          dx = LARGE_RADIUS.round(2)
          dy = LARGE_RADIUS.round(2)

          color = color_for(@future_label.color) || (Lib::Hex::COLOR[@future_label.color || 'white'])
          children = [h(:g, [
            h(:polygon,
              attrs: { points: hex_points(LARGE_RADIUS, dx, dy), fill: color }),
            h('text.tile__text',
              { attrs: { x: dx, y: dy } },
              @future_label.label.to_s),
          ].compact)]

          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-LARGE_RADIUS} #{-LARGE_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
        end
      end
    end
  end
end
