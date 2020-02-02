# frozen_string_literal: true

require 'snabberb/component'

require 'view/slot'

module View
  class City < Snabberb::Component
    needs :city
    needs :x
    needs :y

    def render
      slot_radius = 25

      slots = (0..(@city.slots - 1)).zip(@city.tokens).map do |slot_index, token|
        rotation = (360 / @city.slots) * slot_index

        # use the rotation on the outer <g> to position the slot, then use
        # -rotation on the Slot so its contents are rendered without
        # rotation
        h(:g, { attrs: { 'stroke-width': 1, transform: "rotate(#{rotation})" } }, [
            h(:g, { attrs: { transform: "translate(#{@x}, #{@y}) rotate(#{rotation})" } }, [
                h(Slot, city: @city,
                        token: token,
                        slot_index: slot_index,
                        radius: slot_radius,
                        reservation: @city.reservations[slot_index])
              ].compact)
          ])
      end

      [h(:g, slots)]
    end
  end
end
