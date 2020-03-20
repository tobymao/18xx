# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TrackLawsonPath < Base
      needs :path
      needs :color, default: 'black'

      def load_from_tile
        @edge_num = @path.edges.first.num
      end

      def preferred_render_locations
        regions = {
          0 => [15, 21],
          1 => [13, 14],
          2 => [6, 7],
          3 => [2, 8],
          4 => [9, 10],
          5 => [16, 17],
        }[@edge_num]

        [
          {
            region_weights: {
              regions => 1.0,
            },
            x: 0,
            y: 0,
          }
        ]
      end

      def render_part
        rotation = 60 * @edge_num

        props = {
          attrs: {
            class: 'lawson_path',
            transform: "rotate(#{rotation})",
            d: 'M 0 87 L 0 0',
            stroke: @color,
            'stroke-width' => 8
          }
        }

        [
          h(:path, props),
        ]
      end
    end
  end
end
