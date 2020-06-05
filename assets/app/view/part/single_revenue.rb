# frozen_string_literal: true

require 'view/part/base'
require 'view/part/multi_revenue'

module View
  module Part
    class SingleRevenue < Snabberb::Component
      needs :revenue
      needs :transform, default: 'translate(0 0)'

      def render
        text_attrs = {
          fill: 'black',
          transform: 'translate(0 6)',
          'text-anchor': 'middle',
        }

        h(
          :g,
          { attrs: { transform: @transform } },
          [
            h(:circle, attrs: { r: 14, fill: 'white' }),
            h(:text, { attrs: text_attrs }, @revenue),
          ]
        )
      end
    end
  end
end
