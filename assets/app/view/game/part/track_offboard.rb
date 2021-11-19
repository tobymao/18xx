# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class TrackOffboard < Base
        PARALLEL_SPACING = [8, 6, 4].freeze

        needs :path
        needs :offboard
        needs :border_props, default: nil
        needs :color, default: 'black'
        needs :width, default: 8
        needs :dash, default: '0'

        REGIONS = {
          0 => [21],
          1 => [13],
          2 => [6],
          3 => [2],
          4 => [10],
          5 => [17],
        }.freeze

        def calculate_shift(lane)
          ((lane[1] * 2) - lane[0] + 1) * (@width.to_i + PARALLEL_SPACING[lane[0] - 2]) / 2.0
        end

        def edge
          @edge ||= @path.exits[0]
        end

        def preferred_render_locations
          [
            {
              region_weights: REGIONS[edge],
              x: 0,
              y: 0,
            },
          ]
        end

        def build_props(color, width, dash)
          rotate = 60 * edge

          d_width = width.to_i / 2
          offboard_start_x = d_width
          offboard_end_x = -d_width
          begin_lane, = @path.lanes
          if begin_lane[0] > 1
            begin_shift = calculate_shift(begin_lane)
            offboard_start_x += begin_shift
            offboard_end_x += begin_shift
          end
          point_x = (offboard_start_x + offboard_end_x) / 2

          {
            attrs: {
              transform: "rotate(#{rotate})",
              d: "M #{offboard_start_x} 75 L #{offboard_start_x} 87 L #{offboard_end_x} 87 "\
                 "L #{offboard_end_x} 75 L #{point_x} 48 Z",
              fill: color,
              stroke: 'none',
              'stroke-linecap': 'butt',
              'stroke-linejoin': 'miter',
              'stroke-width': width.to_i * 0.75,
              'stroke-dasharray': dash,
            },
          }
        end

        def render_part
          [h(:path, build_props(@border_props['color'], @width + @border_props['width'], '0')),
           h(:path, build_props(@color, @width, @dash))]
        end
      end
    end
  end
end
