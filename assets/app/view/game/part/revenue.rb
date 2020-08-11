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

            top_weights = if layout == :flat
                            { TOP_MIDDLE_ROW => 1.5 }
                          else
                            { [2, 6, 7, 8] => 1.5, [3, 5] => 0.5 }
                          end

            bottom_weights = if layout == :flat
                               { BOTTOM_MIDDLE_ROW => 1.5 }
                             else
                               { [15, 16, 21, 17] => 1.5, [18, 20] => 0.5 }
                             end

            [
              {
                region_weights: { CENTER => 1.5 },
                x: 0,
                y: 0,
              },
              {
                region_weights: top_weights,
                x: 0,
                y: -48,
              },
              {
                region_weights: bottom_weights,
                x: 0,
                y: 45,
              },
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
