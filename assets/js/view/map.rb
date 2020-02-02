# frozen_string_literal: true

require 'view/hex'
require 'view/tile_confirmation'
require 'view/tile_selector'

module View
  class Map < Snabberb::Component
    needs :game, store: true
    needs :tile_selector, default: nil, store: true

    def render
      hexes = @game.map.hexes.dup
      # move the selected hex to the back so it renders highest in z space
      hexes << hexes.delete(@tile_selector.hex) if @tile_selector
      hexes.map! { |hex| h(Hex, hex: hex, game: @game) }

      children = [
        h(:svg, { style: { width: '100%', height: '800px' } }, [
          h(:g, { attrs: { transform: 'scale(0.5)' } }, hexes)
        ]),
      ]

      if @tile_selector
        children << h(TileSelector, tiles: @game.upgrades_for_tile(@tile_selector.tile))
        children << h(TileConfirmation) if @tile_selector.tile
      end

      h(:div, children)
    end
  end
end
