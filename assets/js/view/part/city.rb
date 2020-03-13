# frozen_string_literal: true

require 'view/part/base'
require 'view/part/city_slot'

module View
  module Part
    class City < Base
      needs :city

      # key is how many city slots are part of the city; value is the offset for
      # the first city slot
      CITY_SLOT_POSITION = {
        1 => [0, 0],
        2 => [-25, 0],
        3 => [0, -29],
        4 => [-25, -25],
        5 => [0, -43],
        6 => [0, -50],
      }.freeze

      def preferred_render_locations
        regions =
          case @city.slots
          when 1
            ['center']
          when (2..4)
            ['center', 'half_corner1.5', 'half_corner4.5', 'half_edge1', 'half_edge2', 'half_edge4', 'half_edge5']
          else
            ['center']
          end

        [
          {
            regions: regions,
            transform: '',
          }
        ]
      end

      # TODO: render white "background" before slots
      def render_part
        x, y = CITY_SLOT_POSITION[@city.slots]

        slot_radius = 25

        slots = (0..(@city.slots - 1)).zip(@city.tokens).map do |slot_index, token|
          rotation = (360 / @city.slots) * slot_index

          # use the rotation on the outer <g> to position the slot, then use
          # -rotation on the Slot so its contents are rendered without
          # rotation
          h(:g, { attrs: { 'stroke-width': 1, transform: "rotate(#{rotation})" } }, [
              h(:g, { attrs: { transform: "translate(#{x}, #{y}) rotate(#{rotation})" } }, [
                  h(CitySlot, city: @city,
                              token: token,
                              slot_index: slot_index,
                              radius: slot_radius,
                              reservation: @city.reservations[slot_index])
                ].compact)
            ])
        end

        h(:g, { attrs: { class: 'city' } }, slots)
      end
    end
  end
end
