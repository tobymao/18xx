# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/multi_revenue'

module View
  module Game
    module Part
      class SingleRevenue < Snabberb::Component
        needs :revenue
        needs :transform, default: 'translate(0 0)'
        needs :force, default: nil

        def render
          return h(:g) if @revenue.zero? && !@force

          circle_props = {
            attrs: {
              r: radius_for_revenue(@revenue),
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
          }

          text_props[:style] = { fontSize: '18px' } if @revenue > 99

          h(
            :g,
            { attrs: { transform: @transform } },
            [
              h(:circle, circle_props),
              h('text.number', text_props, @revenue),
            ]
          )
        end

        def radius_for_revenue(_revenue)
          if @revenue > 99
            17
          elsif @revenue.negative?
            18
          else
            15
          end
        end
      end
    end
  end
end
