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
              region_weights: [13, 14, 15, 16, 17],
              x: -30,
              y: 20,
            },
            {
              region_weights: [6, 7, 8, 9, 10],
              x: -30,
              y: -20,
            },
          ]
        end

        case @slots
        when 1
          [
            {
              region_weights: [6, 7, 13, 14],
              x: -45,
              y: 0,
            },
            {
              region_weights: [9, 10, 16, 17],
              x: 45,
              y: 0,
            },
            {
              region_weights: [13, 14],
              x: -45,
              y: 5,
            },
            {
              region_weights: LEFT_CORNER,
              x: -65,
              y: 0,
            },
            {
              region_weights: RIGHT_CORNER,
              x: 65,
              y: 0,
            },
          ]
        when (2..4)
          [
            {
              region_weights: LEFT_CORNER,
              x: -70,
              y: 0,
            },
            {
              region_weights: RIGHT_CORNER,
              x: 70,
              y: 0,
            },
            {
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

        revenue_stops = @tile.cities + @tile.towns + @tile.offboards
        revenues = revenue_stops.map(&:revenue).uniq

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
