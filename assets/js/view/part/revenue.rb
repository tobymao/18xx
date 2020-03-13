# frozen_string_literal: true

require 'view/part/base'
require 'view/part/multi_revenue'

module View
  module Part
    class Revenue < Base
      needs :tile

      def preferred_render_locations
        if multi_revenue?
          return [
            {
              regions: %w[half_edge5 half_edge0 half_edge1],
              transform: 'translate(-30 20)',
            },
            {
              regions: %w[half_edge2 half_edge3 half_edge4],
              transform: 'translate(-30 -20)',
            },
          ]
        end

        case @slots
        when 1
          [
            {
              regions: ['half_corner1.5', 'half_edge1', 'half_edge2'],
              transform: 'translate(-45 0)',
            },
            {
              regions: ['half_corner4.5', 'half_edge4', 'half_edge5'],
              transform: 'translate(45 0)',
            },
            {
              regions: %w[half_edge1 edge1],
              transform: 'translate(-45 25)',
            },
            {
              regions: ['corner1.5'],
              transform: 'translate(-65 0)',
            },
            {
              regions: ['corner4.5'],
              transform: 'translate(65 0)',
            },
          ]
        when (2..4)
          [
            {
              regions: ['corner1.5'],
              transform: 'translate(-70 0)',
            },
            {
              regions: ['corner4.5'],
              transform: 'translate(70 0)',
            },
            {
              regions: ['half_edge1'],
              transform: 'translate(-45 25)',
            },
          ]
        else
          [
            {
              regions: ['center'],
              transform: 'translate(0 0)',
            }
          ]
        end
      end

      def parse_tile
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
          h(Part::MultiRevenue, revenues: @revenue, translate: transform)
        else
          attrs = {
            class: 'revenue',
            'stroke-width': 1,
            transform: transform,
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
