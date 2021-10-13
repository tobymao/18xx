# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class TrackStub < Base
        needs :stub
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

        def load_from_tile
          @edge = @stub.edge
        end

        def preferred_render_locations
          [
            {
              region_weights: REGIONS[@edge],
              x: 0,
              y: 0,
            },
          ]
        end

        def build_props(color, width, dash)
          rotate = 60 * @edge

          {
            attrs: {
              transform: "rotate(#{rotate})",
              d: 'M 0 87 L 0 65',
              fill: color,
              stroke: color,
              'stroke-linecap': 'butt',
              'stroke-linejoin': 'miter',
              'stroke-width': width,
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
