# frozen_string_literal: true

require 'view/game/hit_box'
require 'view/game/part/base'
require 'view/game/runnable'

module View
  module Game
    module Part
      class TownDot < Base
        include Runnable

        needs :color, default: 'black'
        needs :tile
        needs :town
        needs :width, default: 8

        REVENUE_DISPLACEMENT = 42
        REVENUE_ANGLE = -60

        REVENUE_REGIONS = {
          flat: [9, 16],
          pointy: [8, 9],
        }.freeze

        CENTER_TOWN = [
          {
            region_weights: CENTER,
            x: 0,
            y: 0,
          },
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
          @tile.towns.size > 1 ? OFFSET_TOWNS : CENTER_TOWN
        end

        def render_revenue
          revenues = @tile.towns.first.revenue.values.uniq
          return unless revenues.one?

          revenue = revenues.first

          angle = layout == :pointy ? -60 : 0

          increment_weight_for_regions(REVENUE_REGIONS[layout])
          h(:g, { attrs: { transform: "rotate(#{angle})" } }, [
              h(:g, { attrs: { transform: "translate(#{REVENUE_DISPLACEMENT} 0) rotate(#{-angle})" } }, [
                  h(Part::SingleRevenue,
                    revenue: revenue,
                    transform: rotation_for_layout),
                ]),
            ])
        end

        def render_part
          children = [h(:circle, attrs: { transform: translate, fill: @color, r: 10 * (0.8 + @width.to_i / 40) })]
          children << render_revenue
          children << h(HitBox, click: -> { touch_node(@town) }, transform: translate) unless @town.solo?
          h(:g, children)
        end
      end
    end
  end
end
