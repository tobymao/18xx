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

        EDGE_TRACK_REGIONS = {
          0 => TRACK_TO_EDGE_0,
          0.5 => TRACK_TO_EDGE_0P5,
          1 => TRACK_TO_EDGE_1,
          1.5 => TRACK_TO_EDGE_1P5,
          2 => TRACK_TO_EDGE_2,
          2.5 => TRACK_TO_EDGE_2P5,
          3 => TRACK_TO_EDGE_3,
          3.5 => TRACK_TO_EDGE_3P5,
          4 => TRACK_TO_EDGE_4,
          4.5 => TRACK_TO_EDGE_4P5,
          5 => TRACK_TO_EDGE_5,
          5.5 => TRACK_TO_EDGE_5P5,
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
          4 => [10, 11, 4, 9],
          4.5 => [9, 10, 11, 16, 17, 18],
          5 => [16, 17, 18, 23],
          5.5 => [15, 16, 17, 21, 22, 23],
        }.freeze

        EXTRA_SLOT_REGIONS = {
          0 => [13, 14, 16, 17, 19, 23],
          0.5 => [12, 22],
          1 => [6, 7, 15, 21, 5, 20],
          1.5 => [0, 19],
          2 => [2, 8, 14, 13, 1, 12],
          2.5 => [3, 5],
          3 => [10, 9, 7, 6, 4, 0],
          3.5 => [1, 11],
          4 => [17, 16, 8, 2, 18, 3],
          4.5 => [4, 17],
          5 => [21, 15, 9, 10, 22, 11],
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

        OO_REVENUE_REGIONS = [
          [[19], true],
          [[5, 12], true],
          [[5, 12], false],
          [[4], true],
          [[11, 18], true],
          [[11, 18], false],
        ].freeze

        def preferred_render_locations
          if @edge
            weights = EDGE_TRACK_REGIONS[@edge] + EDGE_CITY_REGIONS[@edge]
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
                (LEFT_CENTER + LEFT_MID + RIGHT_CENTER + RIGHT_MID) => 0.5,
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
          @num_cities = @tile.cities.size
        end

        def render_part
          slots = (0..(@city.slots - 1)).zip(@city.tokens).map do |slot_index, token|
            slot_rotation = (360 / @city.slots) * slot_index

            # use the rotation on the outer <g> to position the slot, then use
            # -rotation on the Slot so its contents are rendered without
            # rotation
            x, y = CITY_SLOT_POSITION[@city.slots]
            revert_angle = render_location[:angle] + slot_rotation
            revert_angle -= angle_for_layout if @num_cities == 1 || !@edge
            h(:g, { attrs: { transform: "rotate(#{slot_rotation})" } }, [
              h(:g, { attrs: { transform: "translate(#{x.round(2)} #{y.round(2)}) rotate(#{-revert_angle})" } }, [
                h(CitySlot, city: @city,
                            num_cities: @num_cities,
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

        def render_revenue
          revenues = @city.uniq_revenues
          return if revenues.size > 1

          revenue = revenues.first
          return if revenue.zero?

          regions = []

          displacement = REVENUE_DISPLACEMENT[layout][@city.slots]

          rotation = 0

          case @num_cities
          when 1

            rotation = angle_for_layout

            regions = if layout == :flat
                        @city.slots == 1 ? [9, 16] : [11, 18]
                      else
                        @city.slots == 1 ? [8, 9] : [3, 4]
                      end
          when 2
            if @edge
              regions, negative_displacement = OO_REVENUE_REGIONS[@edge]
              displacement *= -1 if negative_displacement
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
