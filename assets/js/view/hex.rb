# frozen_string_literal: true

module View
  class Hex < Snabberb::Component
    SIZE = 100
    POINTS = '100,0 50,-87 -50,-87 -100,-0 -50,87 50,87'
    LAYOUT = {
      flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
      pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
    }.freeze

    needs :tile, default: nil
    needs :hex

    def render
      children = [h(:polygon, attrs: { points: self.class::POINTS })]

      props = {
        attrs: {
          transform: transform,
          fill: @tile&.color || 'white',
          stroke: 'black'
        },
      }

      h(:g, props, children)
    end

    def translation
      t_x, t_y = LAYOUT[@hex.layout]
      "translate(#{t_x * @hex.x + SIZE}, #{t_y * @hex.y + SIZE})"
    end

    def transform
      "#{translation}#{@hex.layout == :pointy ? ' rotate(30)' : ''}"
    end
  end
end
