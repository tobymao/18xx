# frozen_string_literal: true

require 'view/axis'
require 'view/hex'
require 'view/tile_confirmation'
require 'view/tile_selector'

module View
  class Map < Snabberb::Component
    needs :game, store: true
    needs :tile_selector, default: nil, store: true
    needs :selected_company, default: nil, store: true

    GAP = 50 # gap between the row/col labels and the map hexes

    def render
      @hexes = @game.hexes.dup
      @cols = @hexes.map(&:x).uniq.sort.map(&:next)
      @rows = @hexes.map(&:y).uniq.sort.map(&:next)
      @layout = @game.layout
      @round = @game.round

      # move the selected hex to the back so it renders highest in z space
      @hexes << @hexes.delete(@tile_selector.hex) if @tile_selector
      special_hexes, special_tiles = @game.special.layable_hexes(@selected_company)

      @hexes.map! do |hex|
        layable =
          if special_hexes
            special_hexes.key?(hex)
          elsif @round.operating?
            @round.layable_hexes.key?(hex)
          else
            false
          end
        h(Hex, hex: hex, layable: layable)
      end

      children = [render_map]

      if @tile_selector
        tiles =
          if special_tiles
            special_tiles
          else
            colors = game.phase.tiles
            potential = @game.tiles.select { |tile| colors.include?(tile.color) }
            @tile_selector.tile.upgrade_tiles(potential)
          end

        children << render_tile_selector(tiles, special_tiles ? @game.special : @round)
      end

      h(:div, { style: { overflow: 'auto' } }, children)
    end

    def render_map
      w_size, h_size = @layout == :flat ? [100, 50] : [50, 100]
      width = @cols.size * w_size
      height = @rows.size * h_size

      h(:svg, { attrs: { id: 'map' }, style: { width: width, height: height } }, [
        h(:g, { attrs: { transform: 'scale(0.5)' } }, [
          h(:g, { attrs: { id: 'map-hexes', transform: "translate(#{25 + GAP} #{12.5 + GAP})" } }, @hexes),
          h(Axis, cols: @cols, rows: @rows, layout: @layout, gap: GAP),
        ])
      ])
    end

    def render_tile_selector(tiles, rotation_checker)
      if @tile_selector.hex.tile == @tile_selector.tile
        tiles.each do |tile|
          tile.rotate!(0) # reset tile to no rotation since calculations are absolute
          tile.legal_rotations = rotation_checker.legal_rotations(@tile_selector.hex, tile)
          tile.rotate!
        end

        tiles.reject! { |tile| tile.legal_rotations.empty? }

        h(TileSelector, tiles: tiles)
      else
        h(TileConfirmation)
      end
    end
  end
end
