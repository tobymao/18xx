# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/base'

module View
  module Part
    class TownRect < Base
      needs :edges
      needs :color, default: 'black'

      def rotation(edge_a, edge_b)
        edge_a += 6 if (edge_b - edge_a).abs > 3
        mean = (edge_a + edge_b) / 2.0

        mean * 60
      end

      def inner_rotation(edge_a, edge_b)
        edge_a += 6 if (edge_b - edge_a).abs > 3
        diff = (edge_a - edge_b).abs

        if diff == 2
          -22
        else
          0
        end
      end

      def delta_x(width, edge_a, edge_b)
        edge_a += 6 if (edge_b - edge_a).abs > 3
        diff = (edge_a - edge_b).abs

        (-width / 2.0) +
          if diff == 1
            0
          elsif diff == 2
            -50
          elsif diff == 3
            40
          end
      end

      def delta_y(height, edge_a, edge_b)
        edge_a += 6 if (edge_b - edge_a).abs > 3
        diff = (edge_a - edge_b).abs

        (-height / 2.0) +
          if diff == 1
            43.5
          elsif diff == 2
            31.575
          elsif diff == 3
            0
          end
      end

      def render
        edge_a, edge_b = @edges
        edge_a, edge_b = edge_b, edge_a if edge_b < edge_a

        angle = rotation(edge_a, edge_b)
        inner_angle = inner_rotation(edge_a, edge_b)

        height = 32
        width = 8

        dx = delta_x(width, edge_a, edge_b)
        dy = delta_y(height, edge_a, edge_b)

        attrs = {
          class: 'town_rect',
          transform: "rotate(#{angle})",
        }

        h(
          :g,
          { attrs: attrs },
          [
            h(
              :rect,
              attrs: {
                transform: "translate(#{dx} #{dy}) rotate(#{inner_angle})",
                height: height,
                width: width,
                fill: @color,
                stroke: 'none'
              },
            ),
          ]
        )
      end
    end
  end
end
