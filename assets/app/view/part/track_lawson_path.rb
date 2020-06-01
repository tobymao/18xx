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
          0 => TRACK_TO_EDGE_0,
          1 => TRACK_TO_EDGE_1,
          2 => TRACK_TO_EDGE_2,
          3 => TRACK_TO_EDGE_3,
          4 => TRACK_TO_EDGE_4,
          5 => TRACK_TO_EDGE_5,
        }[@edge_num]

        [
          {
            region_weights: regions,
            x: 0,
            y: 0,
          },
        ]
      end

      def render_part
        rotation = 60 * @edge_num

        props = {
          attrs: {
            transform: "rotate(#{rotation})",
            d: 'M 0 87 L 0 0',
            stroke: @color,
            'stroke-width' => 8,
          },
        }

        [
          h(:path, props),
        ]
      end
    end
  end
end
