# frozen_string_literal: true

module View
  class Tile < Snabberb::Component
    def render
      h(:g, { attrs: { transform: 'rotate(60)' } }, [
        h(:path, attrs: { d: 'm 0 87 L 0 -87', stroke: 'black', 'stroke-width' => 8 }),
        h(:path, attrs: { d: 'm -4 86 L -4 -86', stroke: 'white', 'stroke-width' => 2 }),
        h(:path, attrs: { d: 'm 4 86 L 4 -86', stroke: 'white', 'stroke-width' => 2 }),
      ])
    end
  end
end
