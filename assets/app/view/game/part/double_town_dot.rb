# frozen_string_literal: true

require 'view/game/hit_box'
require 'view/game/part/base'
require 'view/game/part/single_revenue'
require 'view/game/runnable'

module View
  module Game
    module Part
      class DoubleTownDot < Base
        include Runnable

        needs :color, default: 'black'
        needs :tile
        needs :double_town
        needs :width, default: 8
        needs :show_revenue

        DOT_OFFSET = 12
        PILL_HALF_WIDTH = 14
        REVENUE_DISPLACEMENT = 58

        def preferred_render_locations
          [{ region_weights: CENTER, x: 0, y: 0 }]
        end

        def towns
          @double_town.towns
        end

        def direction(loc, radius)
          angle = @tile.compute_loc(loc) * 60 / 180.0 * Math::PI
          [-Math.sin(angle) * radius, Math.cos(angle) * radius]
        end

        def render_pill
          x, y = direction(@double_town.axis, DOT_OFFSET)

          [
            [(PILL_HALF_WIDTH * 2) + 2, 'black'],
            [(PILL_HALF_WIDTH * 2) - 2, 'white'],
          ].map do |stroke_width, stroke|
            h(:line, attrs: {
                x1: -x.round(2),
                y1: -y.round(2),
                x2: x.round(2),
                y2: y.round(2),
                stroke: stroke,
                'stroke-width': stroke_width,
                'stroke-linecap': 'round',
              })
          end
        end

        def dot_positions
          x, y = direction(@double_town.axis, DOT_OFFSET)
          [[-x, -y], [x, y]]
        end

        def render_dots
          radius = 10 * (0.8 + (@width.to_i / 40))

          dot_positions.map do |cx, cy|
            h(:circle, attrs: {
                cx: cx.round(2),
                cy: cy.round(2),
                r: radius,
                fill: @color,
                stroke: 'white',
                'stroke-width': 4,
              })
          end
        end

        def render_hit_box
          h(HitBox, click: -> { touch_both_towns }, transform: translate, r: DOT_OFFSET + PILL_HALF_WIDTH)
        end

        def render_revenues
          towns.zip(@double_town.revenue_locs).map do |town, loc|
            revenue = town.uniq_revenues.first
            next if revenue.nil? || revenue.zero?

            x, y = direction(loc, REVENUE_DISPLACEMENT)
            h(:g, { key: "#{town.id}-r", attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
              h(Part::SingleRevenue, revenue: revenue, transform: rotation_for_layout),
            ])
          end.compact
        end

        def render_part
          children = render_pill + render_dots
          children.concat(render_revenues) if @show_revenue
          children << render_hit_box
          h(:g, { key: "#{towns.first.id}-d" }, children)
        end

        private

        def touch_both_towns
          return if !@game.active_step.current_actions.include?('run_routes') || !@selected_route

          touch_towns(@selected_route)
          store(:selected_route, @selected_route)
        end

        def touch_towns(route)
          on_route = towns.select { |town| route_nodes(route).include?(town) }

          if on_route.size == 2
            remove_end_towns(route)
          else
            (towns - on_route).each { |town| route.touch_node(town) }
          end
        end

        def remove_end_towns(route)
          while (town = towns.find { |t| route_ends(route).include?(t) })
            route.touch_node(town)
          end
        end

        def route_ends(route)
          return [route.last_node].compact if route.connection_data.empty?

          [route.head[:left], route.tail[:right]]
        end

        def route_nodes(route)
          return [route.last_node].compact if route.connection_data.empty?

          [route.head[:left]] + route.connection_data.map { |connection| connection[:right] }
        end
      end
    end
  end
end
