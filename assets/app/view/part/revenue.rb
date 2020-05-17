# frozen_string_literal: true

require 'view/part/base'
require 'view/part/multi_revenue'

module View
  module Part
    class Revenue < Base
      def preferred_render_locations
        if multi_revenue?
          return [
            {
              region_weights: CENTER,
              x: 0,
              y: 0,
            },
            {
              region_weights: TOP_MIDDLE_ROW,
              x: 0,
              y: -24,
            },
            {
              region_weights: BOTTOM_MIDDLE_ROW,
              x: 0,
              y: 24,
            },
            {
              region_weights: TOP_ROW,
              x: 0,
              y: -48,
            },
            {
              region_weights: BOTTOM_ROW,
              x: 0,
              y: 48,
            },
          ]
        end

        case @slots
        when 1
          [
            {
              # left-center
              region_weights_in: { LEFT_MID => 1.0, LEFT_CENTER => 0.4 },
              region_weights_out: { LEFT_CORNER => 0.1, LEFT_MID => 0.2, LEFT_CENTER => 1.0 },
              x: -45,
              y: 0,
            },
            {
              # right-center
              region_weights_in: { RIGHT_MID => 1.0, RIGHT_CENTER => 0.4 },
              region_weights_out: { RIGHT_CORNER => 0.1, RIGHT_MID => 0.2, RIGHT_CENTER => 1.0 },
              x: 45,
              y: 0,
            },
            {
              # between center and edge1
              region_weights: [13, 14],
              x: -45,
              y: 25,
            },
            {
              # between center and edge2
              region_weights: [6, 7],
              x: -45,
              y: -25,
            },
            {
              # between center and lower left corner
              region_weights_in: { [13, 14, 15, 21] => 0.4, [19, 20] => 1.0 },
              region_weights_out: [13, 14, 15, 19, 20, 21],
              x: -28,
              y: 45,
            },
            {
              # between center and lower right corner
              region_weights_in: { [15, 16, 17, 21] => 0.4, [22, 23] => 1.0 },
              region_weights_out: [15, 16, 17, 21, 22, 34],
              x: 28,
              y: 45,
            },
          ]
        when (2..4)
          [
            {
              # left-corner
              region_weights_in: LEFT_CORNER + LEFT_MID,
              region_weights_out: LEFT_CORNER,
              x: -70,
              y: 0,
            },
            {
              # left-corner
              region_weights_in: RIGHT_CORNER + RIGHT_MID,
              region_weights_out: RIGHT_CORNER,
              x: 70,
              y: 0,
            },
            {
              # between center and edge1
              region_weights: [13, 14],
              x: -45,
              y: 25,
            },
          ]
        else
          [
            {
              region_weights: [7, 8, 9, 14, 15, 16],
              x: 0,
              y: 0,
            }
          ]
        end
      end

      def load_from_tile
        @slots = @tile.cities.map(&:slots).sum + @tile.towns.size

        revenues = @tile.stops.map(&:revenue).uniq

        return if revenues.empty?

        if revenues.size == 1
          revenues = revenues.first
        else
          puts 'WARNING: encountered multiple different revenues on one tile'
          @revenue = nil
          return
        end

        @revenue =
          if revenues.values.uniq.size == 1
            revenues.values.uniq.first
          else
            revenues
          end
      end

      def should_render?
        ![nil, 0].include?(@revenue)
      end

      def multi_revenue?
        !@revenue.is_a?(Numeric)
      end

      def render_part
        text_attrs = {
          fill: 'black',
          transform: 'translate(0 6)',
          'text-anchor': 'middle',
        }

        if multi_revenue?
          h(Part::MultiRevenue, revenues: @revenue, translate: translate)
        else
          attrs = {
            class: 'revenue',
            'stroke-width': 1,
            transform: translate,
          }

          h(
            :g,
            { attrs: attrs },
            [
              h(:circle, attrs: { r: 14, fill: 'white' }),
              h(:text, { attrs: text_attrs }, @revenue),
            ]
          )
        end
      end
    end
  end
end
