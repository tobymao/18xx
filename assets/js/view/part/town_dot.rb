# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TownDot < Base
      needs :color, default: 'black'
      needs :tile

      CENTER_TOWN = [
        {
          region_weights: CENTER,
          x: 0,
          y: 0,
        }
      ].freeze

      OFFSET_TOWNS = [
        {
          region_weights: [13, 14],
          x: -40,
          y: 20,
        },
        {
          region_weights: [9, 10],
          x: 40,
          y: -20,
        },
        {
          region_weights: { [6, 7] => 0.5 },
          x: -40,
          y: -20,
        },
        {
          region_weights: { [16, 17] => 0.5 },
          x: 40,
          y: 20,
        },
      ].freeze

      def preferred_render_locations
        if @tile.towns.size > 1
          CENTER_TOWN
        else
          OFFSET_TOWNS
        end
      end

      def render_part
        attrs = {
          class: 'town_dot',
          transform: translate,
          fill: @color,
          cx: '0',
          cy: '0',
          r: '10',
        }

        h(:circle, attrs: attrs)
      end
    end
  end
end
