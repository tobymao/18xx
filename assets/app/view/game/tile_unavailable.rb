# frozen_string_literal: true

module View
  class TileUnavailable < Snabberb::Component
    needs :unavailable
    needs :layout

    BACKGROUND_COLOR = '#FFFFFF'
    BACKGROUND_OPACITY = '0.75'
    LINE_HEIGHT = 30
    CHARACTER_WIDTH = 16

    def render
      height = LINE_HEIGHT + 10
      width = @unavailable.size * CHARACTER_WIDTH
      y = -(height / 2)
      x = -(width / 2)
      attrs = {
        height: height,
        width: width,
        x: x,
        y: y,
        fill: BACKGROUND_COLOR,
        'fill-opacity': BACKGROUND_OPACITY,
        stroke: 'none',
      }

      text_attrs = {
        'text-anchor': 'middle',
        stroke: 'none',
        fill: 'black',
        transform: "translate(0 #{LINE_HEIGHT / 2}) scale(2)",
      }

      group_attrs = {
        transform: (@layout == :pointy ? ' rotate(-30)' : '').to_s,
      }

      children = [
        # Add a polygon to grey out the tile without making it transparent
        h(:polygon, attrs: { fill: '#ffffff', opacity: 0.5, points: Lib::Hex::POINTS }),
        h(:g, { attrs: group_attrs }, [
          h(:rect, attrs: attrs),
          h(:text, { attrs: text_attrs }, @unavailable),
        ]),
      ]

      h('g.tile_unavailable', children)
    end
  end
end
