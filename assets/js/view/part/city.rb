# frozen_string_literal: true

require 'view/part/base'
require 'view/part/city_slot'

module View
  module Part
    class City < Base
      SLOT_RADIUS = 25

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

      # TODO: render white "background" before slots
      def render_part
        slot_radius = SLOT_RADIUS

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
                              radius: slot_radius,
                              reservation: @city.reservations[slot_index])
                ])
            ])
        end

        children = []

        children << render_box(slots.size) if slots.size > 1

        children += slots

        h(:g, { attrs: { class: 'city' } }, children)
      end

      # TODOS:
      # - do actual math and get points for the 3-slot hexagon, rather than
      #   scaling the full-size hexagon
      # - implement for 4, 5, and 6 slot cities
      def render_box(slots)
        box =
          case slots
          when 2
            h(
              :rect,
              attrs: {
                width: 2 * SLOT_RADIUS,
                height: 2 * SLOT_RADIUS,
                fill: 'white',
                x: -SLOT_RADIUS,
                y: -SLOT_RADIUS,
              }
            )
          when 3
            h(
              :polygon,
              attrs: {
                points: '100,0 50,-87 -50,-87 -100,-0 -50,87 50,87',
                fill: 'white',
                transform: 'scale(0.458)',
              }
            )
          end

        h(:g, { attrs: { class: 'city-box' } }, [
            box
          ])
      end
    end
  end
end
