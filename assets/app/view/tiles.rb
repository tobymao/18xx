# frozen_string_literal: true

require 'view/game/hex'

module View
  class Tiles < Snabberb::Component
    def render_tile_blocks(
      name,
      layout: nil,
      num: nil,
      tile: nil,
      location_name: nil,
      scale: 1.0,
      opacity: 1.0,
      rotations: nil,
      hex_coordinates: nil
    )
      props = {
        style: {
          width: "#{80 * scale}px",
          height: "#{97 * scale}px",
        },
      }

      tile ||= Engine::Tile.for(name)

      loc_name = location_name || tile.location_name if (tile.cities + tile.towns + tile.offboards).any?

      rotations = [0] if tile.preprinted || !rotations

      rotations.map do |rotation|
        tile.rotate!(rotation)

        text = tile.preprinted ? '' : '#'
        text += name
        text += "-#{rotation}" unless rotations == [0]
        text += " × #{num}" if num

        hex = Engine::Hex.new(hex_coordinates || 'A1',
                              layout: layout,
                              location_name: loc_name,
                              tile: tile)
        hex.x = 0
        hex.y = 0

        h('div.tile__block', props, [
            h(:div, { style: { textAlign: 'center', fontSize: '12px' } }, text),
            h(:svg, { style: { width: '100%', height: '100%' } }, [
              h(:g, { attrs: { transform: "scale(#{scale * 0.4})" } }, [
                h(
                  Game::Hex,
                  hex: hex,
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
