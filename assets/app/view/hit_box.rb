# frozen_string_literal: true

module View
  class HitBox < Snabberb::Component
    needs :click
    needs :transform
    needs :r, default: 30

    def render
      h(:circle,
        on: { click: @click },
        style: { cursor: 'pointer', 'pointer-events': 'all' },
        attrs: {
          stroke: 'none',
          transform: @transform,
          r: @r,
        })
    end
  end
end
