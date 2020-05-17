# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    # letter label, like "Z", "H", "OO"
    class Label < Base
      def preferred_render_locations
        left_center = {
          region_weights: { (LEFT_MID + LEFT_CORNER) => 1, LEFT_CENTER => 0.5 },
          x: -55,
          y: 0,
        }

        right_center = {
          region_weights: { (RIGHT_MID + RIGHT_CORNER) => 1, RIGHT_CENTER => 0.5 },
          x: 55,
          y: 0,
        }

        left_corner = {
          region_weights: { LEFT_CORNER => 1.0, (LEFT_CENTER + LEFT_MID) => 0.5 },
          x: -28.5 * 2.5,
          y: 0,
        }

        right_corner = {
          region_weights: { RIGHT_CORNER => 1.0, (RIGHT_CENTER + RIGHT_MID) => 0.5 },
          x: 28.5 * 2.5,
          y: 0,
        }

        edge1 = {
          region_weights: { [13] => 1.0, [12, 14] => 0.5 },
          x: -55,
          y: 25,
        }

        edge2 = {
          region_weights: { [6] => 1.0, [5, 7] => 0.5 },
          x: -55,
          y: -25,
        }

        edge4 = {
          region_weights: { [10] => 1.0, [9, 11] => 0.5 },
          x: 55,
          y: -25,
        }

        edge5 = {
          region_weights: { [17] => 1.0, [16, 18] => 0.5 },
          x: 55,
          y: 25,
        }

        top_center = {
          region_weights: { [2] => 1.0, [1, 3] => 0.5 },
          x: 0,
          y: -60,
        }

        right_of_center = {
          region_weights: { [9, 16] => 1.0, [10, 17] => 0.25 },
          x: 35,
          y: 0,
        }

        if @tile.cities.size > 1
          [
            edge2,
            edge1,
            edge4,
            top_center,
            edge5,
            right_of_center,
          ]
        else
          [
            left_center,
            right_center,
            left_corner,
            right_corner,
          ]
        end
      end

      def load_from_tile
        @label = @tile.label.to_s
      end

      def render_part
        attrs = {
          transform: translate,
        }

        text_attrs = {
          fill: 'black',
          transform: 'scale(2.5)',
          'text-anchor': 'middle',
          'alignment-baseline': 'middle',
          'dominant-baseline': 'middle',
        }

        h('g.label', { attrs: attrs }, [
            h(:text, { attrs: text_attrs }, @label)
          ])
      end
    end
  end
end
