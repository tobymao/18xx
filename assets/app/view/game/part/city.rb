# frozen_string_literal: true

require 'view/game/runnable'
require 'view/game/part/base'
require 'view/game/part/city_slot'
require 'view/game/part/single_revenue'

module View
  module Game
    module Part
      class City < Base
        include Runnable

        SLOT_RADIUS = 25
        SLOT_DIAMETER = 2 * SLOT_RADIUS

        needs :tile
        needs :city
        needs :show_revenue

        # key is how many city slots are part of the city; value is the offset for
        # the first city slot
        CITY_SLOT_POSITION = {
          1 => [0, 0],
          2 => [-SLOT_RADIUS, 0],
          3 => [0, -29],
          4 => [-SLOT_RADIUS, -SLOT_RADIUS],
          5 => [0, -43],
          6 => [0, -50],
        }.freeze

        EDGE_CITY_REGIONS = {
          0 => [15, 20, 21, 22],
          0.5 => [13, 14, 15, 19, 20, 21],
          1 => [12, 13, 14, 19],
          1.5 => [5, 6, 7, 12, 13, 14],
          2 => [0, 5, 6, 7],
          2.5 => [0, 1, 2, 6, 7, 8],
          3 => [1, 2, 3, 8],
          3.5 => [2, 3, 4, 8, 9, 10],
          4 => [4, 9, 10, 11],
          4.5 => [9, 10, 11, 16, 17, 18],
          5 => [16, 17, 18, 23],
          5.5 => [15, 16, 17, 21, 22, 23],
        }.freeze

        EXTRA_SLOT_REGIONS = {
          0 => [13, 14, 16, 17, 19, 20, 22, 23],
          0.5 => [12, 22],
          1 => [5, 6, 7, 12, 15, 19, 20, 21],
          1.5 => [0, 19],
          2 => [0, 1, 2, 5, 8, 14, 13, 12],
          2.5 => [3, 5],
          3 => [0, 1, 3, 4, 6, 7, 9, 10],
          3.5 => [1, 11],
          4 => [17, 16, 18, 8, 2, 18, 3, 4],
          4.5 => [4, 17],
          5 => [21, 15, 22, 23, 9, 10, 11, 18],
          5.5 => [18, 20],
        }.freeze

        BORDER_REGIONS = {
          0 => [15, 7],
          0.5 => [7, 8, 9, 16],
          1 => [14, 8],
          1.5 => [8, 9, 15, 16],
          2 => [7, 9],
          2.5 => [9, 14, 15, 16],
          3 => [8, 16],
          3.5 => [7, 14, 15, 16],
          4 => [9, 15],
          4.5 => [7, 8, 14, 15],
          5 => [16, 14],
          5.5 => [7, 8, 9, 14],
        }.freeze
        # key: number of slots in city
        # value: [element name (sym), element attrs]
        BOX_ATTRS = {
          2 => [:rect, {
            fill: 'white',
            width: SLOT_DIAMETER,
            height: SLOT_DIAMETER,
            x: -SLOT_RADIUS,
            y: -SLOT_RADIUS,
          }],
          3 => [:polygon, {
            fill: 'white',
            # Hex::POINTS scaled by 0.458
            points: '45.8,0 22.9,-39.846 -22.9,-39.846 -45.8,0 -22.9,39.846 22.9,39.846',
          }],
          4 => [:rect, {
            fill: 'white',
            width: SLOT_DIAMETER * 2,
            height: SLOT_DIAMETER * 2,
            x: -SLOT_DIAMETER,
            y: -SLOT_DIAMETER,
            rx: SLOT_RADIUS,
          }],
          5 => [:circle, {
            fill: 'white',
            r: 1.36 * SLOT_DIAMETER,
          }],
          6 => [:circle, {
            fill: 'white',
            r: 1.5 * SLOT_DIAMETER,
          }],
        }.freeze

        # index corresponds to number of slots in the city
        REVENUE_DISPLACEMENT = {
          flat: [nil, 42, 67, 65, 67, 0, 0],
          pointy: [nil, 42, 62, 57],
        }.freeze

        ANGLE_UPPER_RIGHT = -60
        ANGLE_LOWER_RIGHT = 10
        ANGLE_LOWER_LEFT = 170
        ANGLE_UPPER_LEFT = -120

        REVENUE_LOCATIONS_BY_EDGE = {
          0 => [
                { regions: [19], angle: ANGLE_LOWER_LEFT },
                { regions: [14], angle: ANGLE_UPPER_LEFT },
                { regions: [23], angle: ANGLE_LOWER_RIGHT },
                { regions: [16], angle: ANGLE_UPPER_RIGHT },
               ],
          0.5 => [
                   { regions: [12, 13], angle: ANGLE_LOWER_LEFT },
                   { regions: [7, 14], angle: ANGLE_UPPER_LEFT },
                   { regions: [15, 16], angle: ANGLE_UPPER_RIGHT },
                   { regions: [21, 22], angle: ANGLE_LOWER_RIGHT },
                 ],
          1 => [
                { regions: [5], angle: ANGLE_LOWER_LEFT },
                { regions: [7], angle: ANGLE_UPPER_LEFT },
                { regions: [15], angle: ANGLE_UPPER_RIGHT },
                { regions: [20], angle: ANGLE_LOWER_RIGHT },
               ],
          1.5 => [
                   { regions: [0, 6], angle: ANGLE_LOWER_LEFT },
                   { regions: [13, 19], angle: ANGLE_LOWER_RIGHT },
                   { regions: [7, 8], angle: ANGLE_UPPER_LEFT },
                   { regions: [14, 15], angle: ANGLE_UPPER_RIGHT },
                 ],
          2 => [
                { regions: [12], angle: ANGLE_LOWER_RIGHT },
                { regions: [14], angle: ANGLE_UPPER_RIGHT },
                { regions: [8], angle: ANGLE_UPPER_LEFT },
                { regions: [1], angle: ANGLE_LOWER_LEFT },
               ],
          2.5 => [
                   { regions: [5, 6], angle: ANGLE_LOWER_RIGHT },
                   { regions: [7, 14], angle: ANGLE_UPPER_RIGHT },
                   { regions: [8, 9], angle: ANGLE_UPPER_LEFT },
                   { regions: [2, 3], angle: ANGLE_LOWER_LEFT },
                 ],
          3 => [
                { regions: [4], angle: ANGLE_LOWER_LEFT },
                { regions: [0], angle: ANGLE_LOWER_RIGHT },
                { regions: [9], angle: ANGLE_UPPER_LEFT },
                { regions: [7], angle: ANGLE_UPPER_RIGHT },
               ],
          3.5 => [
                   { regions: [10, 11], angle: ANGLE_LOWER_LEFT },
                   { regions: [9, 16], angle: ANGLE_UPPER_LEFT },
                   { regions: [7, 8], angle: ANGLE_UPPER_RIGHT },
                   { regions: [1, 2], angle: ANGLE_LOWER_RIGHT },
                 ],
          4 => [
                { regions: [18], angle: ANGLE_LOWER_LEFT },
                { regions: [16], angle: ANGLE_UPPER_LEFT },
                { regions: [8], angle: ANGLE_UPPER_RIGHT },
                { regions: [3], angle: ANGLE_LOWER_RIGHT },
               ],
          4.5 => [
                   { regions: [4, 10], angle: ANGLE_LOWER_RIGHT },
                   { regions: [17, 23], angle: ANGLE_LOWER_LEFT },
                   { regions: [8, 9], angle: ANGLE_UPPER_RIGHT },
                   { regions: [15, 16], angle: ANGLE_UPPER_LEFT },
                 ],
          5 => [
                { regions: [11], angle: ANGLE_LOWER_RIGHT },
                { regions: [9], angle: ANGLE_UPPER_RIGHT },
                { regions: [15], angle: ANGLE_UPPER_LEFT },
                { regions: [22], angle: ANGLE_LOWER_LEFT },
               ],
          5.5 => [
                   { regions: [17, 18], angle: ANGLE_LOWER_RIGHT },
                   { regions: [14, 15], angle: ANGLE_UPPER_LEFT },
                   { regions: [9, 16], angle: ANGLE_UPPER_RIGHT },
                   { regions: [20, 21], angle: ANGLE_LOWER_LEFT },
                 ],
        }.freeze

        OO_REVENUE_REGIONS = [
          [[19], true],
          [[5, 12], true],
          [[5, 12], false],
          [[4], true],
          [[11, 18], true],
          [[11, 18], false],
        ].freeze

        CENTER_REVENUE_REGIONS = [
          [14, 15],
          [17, 14],
          [7, 8],
          [8, 9],
          [9, 16],
          [15, 16],
        ].freeze

        def preferred_render_locations
          if @edge
            weights = EDGE_CITY_REGIONS[@edge]
            weights += EXTRA_SLOT_REGIONS[@edge] unless @city.slots == 1
            distance = 50

            # If there's a border on this edge, move the city slightly
            # towards the center to ensure track is visible.
            if @tile.borders.any? { |border| border.edge == @edge }
              distance -= 15
              weights = {
                weights => 1.0,
                BORDER_REGIONS[@edge] => 0.1,
              }
            end
            return [
              {
                region_weights: weights,
                x: -Math.sin((@edge * 60) / 180 * Math::PI) * distance,
                y: Math.cos((@edge * 60) / 180 * Math::PI) * distance,
                angle: @edge * 60,
              },
            ]
          end

          region_weights =
            case @city.slots
            when 1
              CENTER
            when (2..4)
              {
                CENTER => 1.0,
                (LEFT_CENTER + LEFT_MID + RIGHT_CENTER + RIGHT_MID) => 0.75,
              }
            else
              CENTER
            end

          [
            {
              region_weights: region_weights,
              x: 0,
              y: 0,
              angle: angle_for_layout, # make center cities always horizontal even on pointy
            },
          ]
        end

        def load_from_tile
          @edge = @tile.preferred_city_town_edges[@city]
          @num_cts = @tile.cities.size + @tile.towns.size
        end

        def render_part
          slots = (0..(@city.slots - 1)).zip(@city.tokens).map do |slot_index, token|
            slot_rotation = (360 / @city.slots) * slot_index

            # use the rotation on the outer <g> to position the slot, then use
            # -rotation on the Slot so its contents are rendered without
            # rotation
            x, y = CITY_SLOT_POSITION[@city.slots]
            revert_angle = render_location[:angle] + slot_rotation
            revert_angle -= angle_for_layout if @num_cts == 1 || !@edge
            h(:g, { attrs: { transform: "rotate(#{slot_rotation})" } }, [
              h(:g, { attrs: { transform: "translate(#{x.round(2)} #{y.round(2)}) rotate(#{-revert_angle})" } }, [
                h(CitySlot, city: @city,
                            num_cities: @num_cts,
                            token: token,
                            slot_index: slot_index,
                            radius: SLOT_RADIUS,
                            reservation: @city.reservations[slot_index],
                            tile: @tile,
                            region_use: @region_use),
              ]),
            ])
          end

          children = []
          children << render_box(slots.size) if slots.size.between?(2, 6)
          children.concat(slots)

          if @show_revenue && (revenue = render_revenue)
            children << revenue
          end

          props = @city.solo? ? {} : { on: { click: -> { touch_node(@city) } } }

          props[:attrs] = { transform: "#{translate} #{rotation}" }

          h(:g, props, children)
        end

        # look for a location for revenue based on edge and region_use
        def find_revenue_location(edge)
          revenue_location = REVENUE_LOCATIONS_BY_EDGE[edge].min_by do |cand|
            combined_cost(cand[:regions])
          end
          [revenue_location[:regions], revenue_location[:angle]]
        end

        def render_revenue
          revenues = @city.uniq_revenues
          return if revenues.size > 1

          revenue = revenues.first
          return if revenue.zero?

          regions = []

          displacement = REVENUE_DISPLACEMENT[layout][@city.slots]

          rotation = 0

          if @num_cts == 1
            rotation = angle_for_layout

            regions = if layout == :flat
                        @city.slots == 1 ? [9, 16] : [11, 18]
                      else
                        @city.slots == 1 ? [8, 9] : [3, 4]
                      end
          elsif @edge && @city.slots == 1
            regions, rotation = find_revenue_location(@edge)
          elsif @edge
            regions, negative_displacement = OO_REVENUE_REGIONS[@edge]
            displacement *= -1 if negative_displacement
          else
            # pick an edge where there isn't another stop
            other_stops = (@tile.cities + @tile.towns).reject { |s| s == @city }
            other_edges = other_stops.map { |s| @tile.preferred_city_town_edges[s] }
              .compact.map { |e| [e, (e - 1).modulo(6)] }
            good_edges = [1, 2, 3, 4, 0, 5] - other_edges.flatten.uniq
            if good_edges.any?
              revenue_edge = good_edges.first
              rotation = 60 * revenue_edge + 120
              regions = CENTER_REVENUE_REGIONS[revenue_edge]
            else
              # give up and pick edge 0
              rotation = 120
              regions = CENTER_REVENUE_REGIONS[0]
            end
          end

          increment_weight_for_regions(regions)

          revert_angle = render_location[:angle] + rotation
          h(:g, { attrs: { transform: "rotate(#{rotation})" } }, [
            h(:g, { attrs: { transform: "translate(#{displacement} 0) rotate(#{-revert_angle})" } }, [
              h(Part::SingleRevenue,
                revenue: revenue,
                transform: rotation_for_layout),
            ]),
          ])
        end

        def render_box(slots)
          element, attrs = BOX_ATTRS[slots]
          h(element, attrs: attrs)
        end
      end
    end
  end
end
