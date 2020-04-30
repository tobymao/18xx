# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TrackOffboard < Base
      needs :path
      needs :color, default: 'black'

      def edge_num
        @edge_num ||= @path.edges.first.num
      end

      def preferred_render_locations
        regions = {
          0 => [21],
          1 => [13],
          2 => [6],
          3 => [2],
          4 => [10],
          5 => [17],
        }[edge_num]

        [
          {
            region_weights: regions,
            x: 0,
            y: 0,
          }
        ]
      end

      def render_part
        rotate = 60 * edge_num

        props = {
          attrs: {
            class: 'track',
            transform: "rotate(#{rotate})",
            d: 'M6 75 L 6 85 L -6 85 L -6 75 L 0 48 Z',
            fill: @color,
            stroke: 'none',
            'stroke-linecap': 'butt',
            'stroke-linejoin': 'miter',
            'stroke-width': 8,
          }
        }

        h(:path, props)
      end
    end
  end
end
