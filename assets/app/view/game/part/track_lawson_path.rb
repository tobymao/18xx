# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class TrackLawsonPath < Base
        needs :path
        needs :color, default: 'black'
        needs :width, default: 8
        needs :dash, default: '0'

        def load_from_tile
          @edge_num = @path.edges.first.num
          @terminal = @path.terminal
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

          props =
            if @terminal == 1
              {
                attrs: {
                  transform: "rotate(#{rotation})",
                  d: 'M6 60 L 6 85 L -6 85 L -6 60 L 0 25 Z',
                  fill: @color,
                  stroke: 'none',
                  'stroke-linecap': 'butt',
                  'stroke-linejoin': 'miter',
                  'stroke-width': @width.to_i * 0.75,
                  'stroke-dasharray': @dash,
                 },
              }
            else
              {
                attrs: {
                  transform: "rotate(#{rotation})",
                  d: 'M 0 87 L 0 0',
                  stroke: @color,
                  'stroke-width': @width,
                  'stroke-dasharray': @dash,
                },
              }
            end

          [
            h(:path, props),
          ]
        end
      end
    end
  end
end
