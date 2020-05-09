# frozen_string_literal: true

module View
  class Tiles < Snabberb::Component
    def render_tile_block(name, num: nil, tile: nil, location_name: nil, scale: 1.0)
      props = {
        style: {
          display: 'inline-block',
          width: "#{80 * scale}px",
          height: "#{97 * scale}px",
          padding: '0.1em',
          margin: '10px 1px 10px 0',
          'outline-style': 'solid',
          'outline-width': 'thin',
        },
      }

      text = num ? "#{name} x #{num}" : name

      h(:div, props, [
          h(:div, { style: { 'text-align': 'center', 'font-size': '12px' } }, text),
        h(:svg, { style: { width: '100%', height: '100%' } }, [
          h(:g, { attrs: { transform: "scale(#{scale * 0.4})" } }, [
            h(
              Hex,
              hex: Engine::Hex.new('A1',
                                   layout: 'flat',
                                   location_name: location_name,
                                   tile: tile || Engine::Tile.for(name)),
              role: :tile_page
            )
          ])
        ])
      ])
    end
  end
end
