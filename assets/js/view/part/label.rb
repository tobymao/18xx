# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    # letter label, like "Z", "H", "OO"
    class Label < Base
      def preferred_render_locations
        [
          {
            region_weights: { LEFT_CENTER => 1.0 },
            x: -22,
            y: 0,
          },
          {
            region_weights: { RIGHT_CENTER => 1.0 },
            x: 22,
            y: 0,
          },
          {
            region_weights: { LEFT_CORNER => 1.0, LEFT_CENTER => 0.5 },
            x: -28.5,
            y: 0,
          },
          {
            region_weights: { RIGHT_CORNER => 1.0, RIGHT_CENTER => 0.5 },
            x: 28.5,
            y: 0,
          },
        ]
      end

      def load_from_tile
        @label = @tile.label.to_s
      end

      def should_render?
        !@label.empty?
      end

      def render_part
        attrs = {
          class: 'label',
          fill: 'black',
          transform: "scale(2.5) #{translate}",
          'text-anchor': 'middle',
          'alignment-baseline': 'middle',
          'dominant-baseline': 'middle',
        }

        h(:text, { attrs: attrs }, @label)
      end
    end
  end
end
