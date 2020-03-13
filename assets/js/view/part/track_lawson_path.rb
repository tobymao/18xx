# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TrackLawsonPath < Base
      needs :path
      needs :color, default: 'black'

      def parse_tile
        @edge_num = @path.edges.first.num
      end

      def preferred_render_locations
        rotation = 60 * @edge_num

        [
          {
            regions: ['center', "edge#{@edge_num}", "half_edge#{@edge_num}"],
            transform: "rotate(#{rotation})",
          }
        ]
      end

      def render_part
        props = {
          attrs: {
            class: 'lawson_path',
            transform: transform,
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
