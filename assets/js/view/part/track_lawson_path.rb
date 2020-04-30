# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TrackLawsonPath < Base
      needs :path
      needs :color, default: 'black'
      needs :ocolor, default: 'white'

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
          }
        ]
      end

      def render_part
        rotation = 60 * @edge_num
        uprops = {
          attrs: {
            class: 'lawson_path',
            transform: "rotate(#{rotation})",
            d: 'M 0 87 L 0 0',
            stroke: @path.gauge != :dual ? @ocolor : @color,
            'stroke-width' => 14
          }
        }

        props = {
          attrs: {
            class: 'lawson_path',
            transform: "rotate(#{rotation})",
            d: 'M 0 87 L 0 0',
            stroke: @path.gauge != :dual ? @color : @ocolor,
            'stroke-dasharray': (10 if @path.gauge == :narrow),
            'stroke-width' => 10
          }.compact
        }

        [ h(:path, uprops), h(:path, props), ]
      end
    end
  end
end
