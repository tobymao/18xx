# frozen_string_literal: true

require 'view/hex'

require 'engine/hex'
require 'engine/tile'

module View
  class TileSelector < Snabberb::Component
    needs :selected_hex_info, store: true

    def render
      hexes = [
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('7')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('8')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('9')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('5')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('6')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('57')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('3')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('4')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('5')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('6')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('12')), role: :tile_selector),
        h(Hex, hex: Engine::Hex.new('A1', layout: 'flat', tile: Engine::Tile.for('13')), role: :tile_selector),
      ]

      theta = 360.0 / hexes.size * Math::PI / 180

      hexes = hexes.map.with_index do |hex, index|
        style = {
          position: 'absolute',
          left: Hex::SIZE * Math.cos(index * theta) + 70,
          bottom: Hex::SIZE * Math.sin(index * theta) + 80,
          width: 60,
          height: 60,
          'pointer-events' => 'auto',
        }
        h(:svg, { style: style }, [h(:g, { attrs: { transform: 'scale(0.3)' } }, [hex])])
      end

      style = {
        position: 'absolute',
        left: @selected_hex_info[:x] - 50,
        top: @selected_hex_info[:y] - 50,
        width: '200px',
        height: '200px',
        opacity: 0.8,
        'pointer-events' => 'none',
      }

      h(:div, { style: style }, hexes)
    end
  end
end
