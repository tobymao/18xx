# frozen_string_literal: true

module View
  class Tiles < Snabberb::Component
    def render_tile_blocks(name, num: nil, tile: nil, location_name: nil, scale: 1.0, opacity: 1.0, rotations: nil)
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

      tile ||= Engine::Tile.for(name)

      loc_name = location_name || tile.location_name if tile.stops.any?

      rotations = [0] if tile.preprinted || !rotations

      rotations.map do |rotation|
        tile.rotate!(rotation)

        text = "##{name}"
        text += "-#{rotation}" if rotations.size > 1
        text += " × #{num}" if num

        h(:div, props, [
            h(:div, { style: { 'text-align': 'center', 'font-size': '12px' } }, text),
            h(:svg, { style: { width: '100%', height: '100%' } }, [
              h(:g, { attrs: { transform: "scale(#{scale * 0.4})" } }, [
                h(
                  Hex,
                  hex: Engine::Hex.new('A1',
                                       layout: 'flat',
                                       location_name: loc_name,
                                       tile: tile),
                  role: :tile_page,
                  opacity: opacity,
                ),
              ]),
            ]),
        ])
      end
    end
  end
end
