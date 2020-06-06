# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/multi_revenue'

module View
  module Game
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
end
