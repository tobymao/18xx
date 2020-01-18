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
    LAYOUT = {
      flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
      pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
    }

    needs :tile, default: nil
    needs :hex

    def render
      children = [h(:polygon, attrs: { points: self.class::POINTS })]
      children << h(@tile) if @tile
      h(:g, { attrs: { transform: transform, fill: @tile&.color || 'white', stroke: 'black' } }, children)
    end

    def translation
      t_x, t_y = LAYOUT[@hex.layout]
      "translate(#{t_x * @hex.x + SIZE}, #{t_y * @hex.y + SIZE})"
    end

    def transform
      "#{translation}#{@hex.layout == :pointy ? ' rotate(30)' : ''}"
    end
  end

  class Map < Snabberb::Component
    needs :game

    def render
      hexes = @game.map.hexes.map do |hex|
        h(Hex, hex: hex)
      end

      h(:svg, { style: { width: '100%', height: '800px' } }, [
        h(:g, { attrs: { transform: 'scale(0.5)' } }, hexes)
      ])
    end
  end
end
