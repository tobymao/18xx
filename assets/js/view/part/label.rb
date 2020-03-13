# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    # letter label, like "Z", "H", "OO"
    class Label < Base
      needs :tile

      def preferred_render_locations
        [
          {
            regions: ['half_corner1.5', 'half_edge1', 'half_edge2'],
            transform: 'translate(-22 0)',
          },
          {
            regions: ['half_corner4.5', 'half_edge4', 'half_edge5'],
            transform: 'translate(22 0)',
          },
          {
            regions: ['corner1.5', 'edge1', 'edge2'],
            transform: 'translate(-28.5 0)',
          },
          {
            regions: ['corner4.5', 'edge4', 'edge5'],
            transform: 'translate(28.5 0)',
          },
        ]
      end

      def parse_tile
        @label = @tile.label.to_s
      end

      def should_render?
        !@label.empty?
      end

      def render_part
        attrs = {
          class: 'label',
          fill: 'black',
          transform: "scale(2.5) #{transform}",
          'text-anchor': 'middle',
          'alignment-baseline': 'middle',
          'dominant-baseline': 'middle',
        }

        h(:text, { attrs: attrs }, @label)
      end
    end
  end
end
