# frozen_string_literal: true

require 'snabberb/component'

module View
  module Part
    class TownRect < Snabberb::Component
      needs :height
      needs :rotation
      needs :translation

      def render
        width = 8

        attrs = {
          class: 'town_rect',
          transform: "rotate(#{@rotation})",
        }

        h(
          :g,
          { attrs: attrs },
          [
            h(
              :rect,
              attrs: {
                transform: "translate(#{-(width / 2)} #{@translation})",
                height: @height,
                width: width,
                fill: 'black'
              },
            ),
          ]
        )
      end
    end
  end
end
