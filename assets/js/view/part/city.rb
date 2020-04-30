# frozen_string_literal: true

require 'lib/hex'
require 'view/part/base'
require 'view/part/city_slot'

module View
  module Part
    class City < Base
      SLOT_RADIUS = 25
      SLOT_DIAMETER = 2 * SLOT_RADIUS

      needs :tile
      needs :edges
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

      EDGE_TRACK_LOCATIONS = [
        TRACK_TO_EDGE_0,
        TRACK_TO_EDGE_1,
        TRACK_TO_EDGE_2,
        TRACK_TO_EDGE_3,
        TRACK_TO_EDGE_4,
        TRACK_TO_EDGE_5,
      ].freeze

      SHARP_TRACK_LOCATIONS = [
        [13, 14, 15, 19, 20, 21],
        [5, 6, 7, 12, 13, 14],
        [0, 1, 2, 6, 7, 8],
        [2, 3, 4, 8, 9, 10],
        [9, 10, 11, 16, 17, 18],
        [15, 16, 17, 21, 22, 23],
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
          points: Lib::Hex::POINTS,
          transform: 'scale(0.458)',
        }],
        4 => [:rect, {
          fill: 'white',
          width: SLOT_DIAMETER * 2,
          height: SLOT_DIAMETER * 2,
          x: -SLOT_DIAMETER,
          y: -SLOT_DIAMETER,
          rx: SLOT_RADIUS
        }],
        5 => [:circle, {
          fill: 'white',
          r: 1.36 * SLOT_DIAMETER
        }],
        6 => [:circle, {
          fill: 'white',
          r: 1.5 * SLOT_DIAMETER
        }],
      }.freeze

      def preferred_render_locations
        edge_a, edge_b = @edges
        if @tile.cities.size > 1 && (edge_a || edge_b)
          if !edge_a || !edge_b
            # We only have one exit, so just draw the city in that region

            edge = edge_a || edge_b

            return [
              {
                region_weights: EDGE_TRACK_LOCATIONS[edge],
                x: -Math.sin((edge * 60) / 180 * Math::PI) * 50,
                y: Math.cos((edge * 60) / 180 * Math::PI) * 50,
              }
            ]
          end

          edge_a += 6 if (edge_b - edge_a).abs > 3
          edge = edge_b < edge_a ? edge_b : edge_a

          # Draw it on edge a for now
          return [
            {
              region_weights: EDGE_TRACK_LOCATIONS[edge],
              x: -Math.sin((edge * 60) / 180 * Math::PI) * 50,
              y: Math.cos((edge * 60) / 180 * Math::PI) * 50,
            }
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
          }
        ]
      end

      def render_part
        slots = (0..(@city.slots - 1)).zip(@city.tokens).map do |slot_index, token|
          rotation = (360 / @city.slots) * slot_index

          # use the rotation on the outer <g> to position the slot, then use
          # -rotation on the Slot so its contents are rendered without
          # rotation
          h(:g, { attrs: { 'stroke-width': 1, transform: "rotate(#{rotation})" } }, [
              h(:g, { attrs: { transform: "#{translate} rotate(#{rotation})" } }, [
                  h(CitySlot, city: @city,
                              token: token,
                              slot_index: slot_index,
                              radius: SLOT_RADIUS,
                              reservation: @city.reservations[slot_index])
                ])
            ])
        end

        children = []

        children << render_box(slots.size) if slots.size.between?(2, 6)

        children += slots

        h('g.city', children)
      end

      # TODOS:
      # - do actual math and get points for the 3-slot hexagon, rather than
      #   scaling the full-size hexagon
      def render_box(slots)
        element, attrs = BOX_ATTRS[slots]
        h("#{element}.city_box", attrs: attrs)
      end
    end
  end
end
