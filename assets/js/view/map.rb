# frozen_string_literal: true

require 'view/axis'
require 'view/hex'
require 'view/tile_confirmation'
require 'view/tile_selector'

module View
  class Map < Snabberb::Component
    needs :game, store: true
    needs :tile_selector, default: nil, store: true

    def render
      hexes = @game.map.hexes.dup

      cols = hexes.map(&:x).uniq.sort.map(&:next)
      rows = hexes.map(&:y).uniq.sort.map(&:next)
      gap = 50 # gap between the row/col labels and the map hexes

      # move the selected hex to the back so it renders highest in z space
      hexes << hexes.delete(@tile_selector.hex) if @tile_selector
      layable_hexes = @game.round.operating? ? @game.round.layable_hexes : {}
      hexes.map! { |hex| h(Hex, hex: hex, layable: layable_hexes.key?(hex)) }

      children = [
        h(:svg, { attrs: { id: 'map' }, style: { width: '1600px', height: '800px' } }, [
            h(:g, { attrs: { transform: 'scale(0.5)' } }, [
                h(:g, { attrs: { id: 'map-hexes', transform: "translate(#{25 + gap} #{12.5 + gap})" } }, hexes),
                h(Axis, cols: cols, rows: rows, layout: @game.layout, gap: gap),
              ])
          ]),
      ]

      if @tile_selector
        tiles = @tile_selector.tile.upgrade_tiles(@game.tiles)

        tiles.each do |tile|
          tile.rotate!(0) # reset tile to no rotation since calculations are absolute
          tile.legal_rotations = @game.round.legal_rotations(@tile_selector.hex, tile)
          tile.rotate!
        end

        children <<
        if @tile_selector.hex.tile == @tile_selector.tile
          h(TileSelector, tiles: tiles)
        else
          h(TileConfirmation)
        end
      end

      h(:div, children)
    end
  end
end
