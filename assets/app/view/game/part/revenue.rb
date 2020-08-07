# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/multi_revenue'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Revenue < Base
        include SmallItem

        def preferred_render_locations
          if multi_revenue?
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
              # {
              #   region_weights: { TOP_ROW => 1.5 },
              #   x: 0,
              #   y: -72,
              # },
              # {
              #   region_weights: { BOTTOM_ROW => 1.5 },
              #   x: 0,
              #   y: 69,
              # },
            ]
          else
            SMALL_ITEM_LOCATIONS
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
