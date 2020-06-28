# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/multi_revenue'

module View
  module Game
    module Part
      class Revenue < Base
        P_RIGHT_CORNER = {
          region_weights: RIGHT_CORNER,
          x: 75,
          y: 0,
        }.freeze

        P_LEFT_CORNER = {
          region_weights: LEFT_CORNER,
          x: -75,
          y: 0,
        }.freeze

        P_UPPER_LEFT_CORNER = {
          region_weights: UPPER_LEFT_CORNER,
          x: -35,
          y: -60.62,
        }.freeze

        P_BOTTOM_LEFT_CORNER = {
          region_weights: BOTTOM_LEFT_CORNER,
          x: -35,
          y: 60.62,
        }.freeze

        P_BOTTOM_RIGHT_CORNER = {
          region_weights: BOTTOM_RIGHT_CORNER,
          x: 35,
          y: 60.62,
        }.freeze

        def preferred_render_locations
          if multi_revenue?
            [
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
          else
            [P_RIGHT_CORNER, P_LEFT_CORNER, P_BOTTOM_RIGHT_CORNER, P_UPPER_LEFT_CORNER, P_BOTTOM_LEFT_CORNER]
          end
        end

        def load_from_tile
          @slots = @tile.cities.map(&:slots).sum + @tile.towns.size
          @cities = @tile.cities.size
          stops = @tile.stops
          @hide = stops.any?(&:hide)

          @revenue = @tile.revenue_to_render.first
        end

        def should_render?
          !@hide && ![nil, 0].include?(@revenue)
        end

        def multi_revenue?
          !@revenue.is_a?(Numeric)
        end

        def render_part
          transform = "#{translate} #{rotation_for_layout}"

          if multi_revenue?
            h(MultiRevenue, revenues: @revenue, transform: transform)
          else
            h(SingleRevenue, revenue: @revenue, transform: transform)
          end
        end
      end
    end
  end
end
