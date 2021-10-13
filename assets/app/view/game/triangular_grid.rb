# frozen_string_literal: true

module View
  class TriangularGrid < Snabberb::Component
    def render
      children = [30, 90, 150].map do |rotate|
        h(:g, { attrs: { transform: "rotate(#{rotate})" } }, [
            h(:path, attrs: { d: 'M 0 100 L 0 -100' }),
            h(:path, attrs: { d: 'M 0 75 L 0 -75', transform: 'translate(-43.5 0)' }),
            h(:path, attrs: { d: 'M 0 75 L 0 -75', transform: 'translate(43.5 0)' }),
          ])
      end

      attrs = {
        fill: 'none',
        opacity: 0.5,
        stroke: 'black',
        'stroke-width' => 2,
      }

      h('g.triangular_grid', { attrs: attrs }, children)
    end
  end
end
