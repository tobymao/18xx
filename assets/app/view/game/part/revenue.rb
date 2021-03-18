# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/multi_revenue'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Revenue < Base
        include SmallItem

        FLAT_MULTI_REVENUE_LOCATIONS =
          [
            {
              region_weights: { CENTER => 1.5 },
              x: 0,
              y: 0,
            },
            {
              region_weights: { TOP_MIDDLE_ROW => 1.5 },
              x: 0,
              y: -48,
            },
            {
              region_weights: { BOTTOM_MIDDLE_ROW => 1.5 },
              x: 0,
              y: 45,
            },
          ].freeze

        POINTY_MULTI_REVENUE_LOCATIONS =
          [
            {
              region_weights: { CENTER => 1.5 },
              x: 0,
              y: 0,
            },
            {
              region_weights: { [2, 6, 7, 8] => 1.5, [3, 5] => 0.5 },
              x: 0,
              y: -55,
            },
            {
              region_weights: { [15, 16, 21, 17] => 1.5, [18, 20] => 0.5 },
              x: 0,
              y: 55,
            },
          ].freeze

        SIX_CITY_CENTER_REVENUE = [
          {
            region_weights: CENTER,
            x: 0,
            y: 0,
          },
        ].freeze

        def preferred_render_locations
          if multi_revenue?
            if layout == :flat
              FLAT_MULTI_REVENUE_LOCATIONS
            else
              POINTY_MULTI_REVENUE_LOCATIONS
            end
          elsif @cities == 6
            SIX_CITY_CENTER_REVENUE
          elsif layout == :flat
            SMALL_ITEM_LOCATIONS
          else
            POINTY_SMALL_ITEM_LOCATIONS
          end
        end

        def load_from_tile
          @slots = @tile.cities.sum(&:slots) + @tile.towns.size
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
          transform = "#{rotation_for_layout} #{translate}"

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
