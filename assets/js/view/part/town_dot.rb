# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TownDot < Base
      def preferred_render_locations
        [
          {
            region_weights: { [7, 8, 9, 14, 15, 16] => 1.0 },
            x: 0,
            y: 0,
          },
        ]
      end

      def render_part
        attrs = {
          class: 'town_dot',
          fill: '#000',
          cx: '0',
          cy: '0',
          r: '10',
        }

        h(:circle, attrs: attrs)
      end
    end
  end
end
