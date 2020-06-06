# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class TrackOffboard < Base
        needs :path
        needs :offboard
        needs :color, default: 'black'

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

          props = {
            attrs: {
              transform: "rotate(#{rotate})",
              d: 'M6 75 L 6 85 L -6 85 L -6 75 L 0 48 Z',
              fill: @color,
              stroke: 'none',
              'stroke-linecap': 'butt',
              'stroke-linejoin': 'miter',
              'stroke-width': 6,
            },
          }

          h(:path, props)
        end
      end
    end
  end
end
