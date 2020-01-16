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

  class Hex < Snabberb::Component
    SIZE = 100
    POINTS = '100,0 50,-87 -50,-87 -100,-0 -50,87 50,87'

    needs :tile, default: nil
    needs :x, default: 0
    needs :y, default: 0

    def render
      children = [h(:polygon, attrs: { points: self.class::POINTS })]
      children << h(@tile) if @tile
      h(:g, { attrs: { transform: transform, fill: @tile&.color || 'white', stroke: 'black' } }, children)
    end

    def translation
      offset = self.class::SIZE
      x = self.class::SIZE * Math.sqrt(3) / 2 * @x + offset
      y = self.class::SIZE * 3 / 2 * @y + offset
      "translate(#{x}, #{y})"
    end

    def transform
      "#{translation} rotate(30)"
    end
  end

  class Map < Snabberb::Component
    needs :game

    def render
      h(:svg, { style: { width: '100%', height: '400px' } }, [
        h(:g, { attrs: { transform: 'scale(0.5)' } }, [
          h(Hex),
          h(Hex, x: 2),
          h(Hex, x: 4),
          h(Hex, x: 1, y: 1),
          h(Hex, x: 3, y: 1),
          h(Hex, x: 2, y: 2),
        ])
      ])
    end
  end
end
