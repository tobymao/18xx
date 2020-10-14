# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class TrackOffboard < Base
        needs :path
        needs :offboard
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

        def render_part
          rotate = 60 * edge

          d_width = @width.to_i / 2

          props = {
            attrs: {
              transform: "rotate(#{rotate})",
              d: "M #{d_width} 75 L #{d_width} 87 L -#{d_width} 87 L -#{d_width} 75 L 0 48 Z",
              fill: @color,
              stroke: 'none',
              'stroke-linecap': 'butt',
              'stroke-linejoin': 'miter',
              'stroke-width': @width.to_i * 0.75,
              'stroke-dasharray': @dash,
            },
          }

          h(:path, props)
        end
      end
    end
  end
end
