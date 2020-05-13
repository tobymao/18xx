# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class Blocker < Base
      def preferred_render_locations
        if @tile.parts.size == 1
          [
            {
              region_weights: CENTER,
              x: 0,
              y: 0,
              scale: 1.5,
            }
          ]
        else
          [
            {
              region_weights: LEFT_CORNER + [13],
              x: -65,
              y: 5,
            },
            {

              region_weights_in: [13, 19, 20],
              region_weights_out: [19, 20],
              x: -35,
              y: 60,
            },
            {
              region_weights_in: [17, 22, 23],
              region_weights_out: [22, 23],
              x: 35,
              y: 60,
            },
          ]
        end
      end

      def load_from_tile
        @blocker = @tile.blockers.first
      end

      def render_part
        h(:g,
          { attrs: { transform: "#{translate} #{scale}", class: 'blocker', } },
          [
            h(:text,
              { attrs: { fill: 'black',
                         'dominant-baseline': 'baseline',
                         'text-anchor': 'middle',
                         x: 0,
                         y: -5 } },
              @blocker.sym),
            h(:path, attrs: { fill: 'white', d: 'M -11 6 A 44 44 0 0 0 11 6' }),
            h(:circle, attrs: { fill: 'white', r: 6, cx: 11, cy: 6 }),
            h(:circle, attrs: { fill: 'white', r: 6, cx: -11, cy: 6 }),
          ])
      end
    end
  end
end
