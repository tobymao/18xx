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
          return h(:g) if @revenue.zero?

          circle_props = {
            attrs: {
              r: @revenue > 99 ? 17 : 15,
              fill: 'white',
            },
            style: {
              stroke: '#777777',
            },
          }
          text_props = {
            attrs: {
              fill: 'black',
              'dominant-baseline': 'central',
              transform: 'translate(0 -1)',
            },
            style: {
              fontSize: @revenue > 99 ? '18px' : '',
            },
          }

          h(
            :g,
            { attrs: { transform: @transform } },
            [
              h(:circle, circle_props),
              h('text.number', text_props, @revenue),
            ]
          )
        end
      end
    end
  end
end
