# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TownDot < Base
      needs :color, default: 'black'

      def preferred_render_locations
        [
          {
            region_weights: [7, 8, 9, 14, 15, 16],
            x: 0,
            y: 0,
          },
        ]
      end

      def render_part
        attrs = {
          class: 'town_dot',
          fill: @color,
          cx: '0',
          cy: '0',
          r: '10',
        }

        h(:circle, attrs: attrs)
      end
    end
  end
end
