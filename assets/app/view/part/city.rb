# frozen_string_literal: true

require 'view/runnable'
require 'view/part/base'
require 'view/part/city_slot'
require 'view/part/single_revenue'

module View
  module Part
    class City < Base
      include Runnable

      SLOT_RADIUS = 25
      SLOT_DIAMETER = 2 * SLOT_RADIUS

      needs :tile
      needs :city

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

      EDGE_TRACK_REGIONS = [
        TRACK_TO_EDGE_0,
        TRACK_TO_EDGE_1,
        TRACK_TO_EDGE_2,
        TRACK_TO_EDGE_3,
        TRACK_TO_EDGE_4,
        TRACK_TO_EDGE_5,
      ].freeze

      EDGE_CITY_REGIONS = [
        [15, 20, 21, 22],
        [12, 13, 14, 19],
        [0, 5, 6, 7],
        [1, 2, 3, 8],
        [10, 11, 4, 9],
        [16, 17, 18, 23],
      ].freeze

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

      OO_REVENUE_ANGLES = [175, -135, 145, -5, 45, -45].freeze

      OO_REVENUE_REGIONS = [
        [19],
        [5, 12],
        [5, 12],
        [4],
        [11, 18],
        [11, 18],
      ].freeze

      def preferred_render_locations
        edge_a, edge_b = @city.exits
        if @num_cities > 1 && (edge_a || edge_b)
          return [
            {
              region_weights: EDGE_TRACK_REGIONS[@edge] + EDGE_CITY_REGIONS[@edge],
              x: -Math.sin((@edge * 60) / 180 * Math::PI) * 50,
              y: Math.cos((@edge * 60) / 180 * Math::PI) * 50,
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

        x, y = CITY_SLOT_POSITION[@city.slots]

        [
          {
            region_weights: region_weights,
            x: x,
            y: y,
          },
        ]
      end

      def load_from_tile
        @edge = @tile.preferred_city_town_edges[@city]
        @num_cities = @tile.cities.size
      end

      def render_part
        slots = (0..(@city.slots - 1)).zip(@city.tokens).map do |slot_index, token|
          rotation = (360 / @city.slots) * slot_index

          # use the rotation on the outer <g> to position the slot, then use
          # -rotation on the Slot so its contents are rendered without
          # rotation
          h(:g, { attrs: { transform: "rotate(#{rotation})" } }, [
              h(:g, { attrs: { transform: "#{translate} rotate(#{-rotation})" } }, [
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

        if (revenue = render_revenue)
          children << revenue
        end

        props = @city.solo? ? {} : { on: { click: -> { touch_node(@city) } } }

        props[:attrs] = { transform: rotation_for_layout } if @tile.cities.size == 1

        h(:g, props, children)
      end

      def render_revenue
        revenues = @city.uniq_revenues
        return if revenues.size > 1

        revenue = revenues.first
        return if revenue.zero?

        # let View::Tile worry about rendering revenue if there are too many
        # individual cities (eg, Chi in 1846)
        return if @num_cities > 2

        angle = angle_for_layout

        x = render_location[:x]
        y = render_location[:y]
        regions = []

        displacement = REVENUE_DISPLACEMENT[layout][1]

        case @num_cities
        when 1
          x = 0
          y = 0

          displacement = REVENUE_DISPLACEMENT[layout][@city.slots]

          regions = if layout == :flat
                      @city.slots == 1 ? [9, 16] : [11, 18]
                    else
                      @city.slots == 1 ? [8, 9] : [3, 4]
                    end
        when 2
          if @edge
            angle = OO_REVENUE_ANGLES[@edge]
            regions = OO_REVENUE_REGIONS[@edge]
          end
        end

        increment_weight_for_regions(regions)

        h(:g, { attrs: { transform: "translate(#{x.round(2)} #{y.round(2)})" } }, [
            h(:g, { attrs: { transform: "rotate(#{angle})" } }, [
                h(:g, { attrs: { transform: "translate(#{displacement} 0)" } }, [
                    h(Part::SingleRevenue,
                      revenue: revenue,
                      transform: "rotate(#{-angle})"),
                  ]),
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
