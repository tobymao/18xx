# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TrackOffboard < Base
      needs :path
      needs :color, default: 'black'

      def parse_tile
        @edge_num = @path.edges.first.num
      end

      def preferred_render_locations
        [
          {
            regions: ["edge#{@edge_num}", "half_edge#{@edge_num}"],
            transform: '',
          }
        ]
      end

      def render_part
        rotate = 60 * @edge_num

        props = {
          attrs: {
            class: 'track',
            transform: "rotate(#{rotate})",
            d: 'M6 75 L 6 85 L -6 85 L -6 75 L 0 48 Z',
            fill: @color,
            stroke: 'none',
            'stroke-linecap': 'butt',
            'stroke-linejoin': 'miter',
            'stroke-width': 6,
          }
        }

        h(:path, props)
      end
    end
  end
end
