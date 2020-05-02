# frozen_string_literal: true

require 'view/axis'
require 'view/hex'
require 'view/tile_confirmation'
require 'view/tile_selector'

module View
  class Map < Snabberb::Component
    needs :game
    needs :tile_selector, default: nil, store: true
    needs :selected_company, default: nil, store: true

    GAP = 50 # gap between the row/col labels and the map hexes

    def render
      @hexes = @game.hexes.dup
      @cols = @hexes.map(&:x).uniq.sort.map(&:next)
      @rows = @hexes.map(&:y).uniq.sort.map(&:next)
      @layout = @game.layout

      @game.special.current_entity = @selected_company

      round =
        if @game.special.tile_laying_ability.any?
          @game.special
        elsif @game.round.operating?
          @game.round
        end

      # move the selected hex to the back so it renders highest in z space
      @hexes << @hexes.delete(@tile_selector.hex) if @tile_selector

      @hexes.map! do |hex|
        h(Hex, hex: hex, round: round)
      end

      children = [render_map]

      if @tile_selector && @tile_selector.hex.tile != @tile_selector.tile
        children << h(TileConfirmation)
      elsif @tile_selector
        tiles = round.upgradeable_tiles(@tile_selector.hex)
        children << h(TileSelector, tiles: tiles)
      end

      props = {
         style: {
           overflow: 'auto',
           margin: '0 -1rem',
         }
      }

      h(:div, props, children)
    end

    def render_map
      w_size, h_size = @layout == :flat ? [85, 50] : [50, 85]
      width = @cols.size * w_size
      height = @rows.size * h_size
      props = {
        attrs: {
          id: 'map',
        },
        style: {
          width: width,
          height: height,
        },
      }

      h(:svg, props, [
        h(:g, { attrs: { transform: 'scale(0.5)' } }, [
          h(:g, { attrs: { id: 'map-hexes', transform: "translate(#{25 + GAP} #{12.5 + GAP})" } }, @hexes),
          h(Axis, cols: @cols, rows: @rows, layout: @layout, gap: GAP),
        ])
      ])
    end
  end
end
