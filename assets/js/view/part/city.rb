# frozen_string_literal: true

require 'lib/hex'
require 'view/part/base'
require 'view/part/city_slot'

module View
  module Part
    class City < Base
      SLOT_RADIUS = 25
      SLOT_DIAMETER = 2 * SLOT_RADIUS

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

      def load_from_tile
        @city = @tile.cities.first
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
      # - implement for 4, 5, and 6 slot cities
      def render_box(slots)
        element, attrs = BOX_ATTRS[slots]
        h("#{element}.city_box", attrs: attrs)
      end
    end
  end
end
