# frozen_string_literal: true

require 'view/game/axis'
require 'view/game/hex'
require 'view/game/tile_confirmation'
require 'view/game/tile_selector'

module View
  module Game
    class Map < Snabberb::Component
      needs :game
      needs :tile_selector, default: nil, store: true
      needs :selected_route, default: nil, store: true
      needs :selected_company, default: nil, store: true
      needs :opacity, default: nil

      GAP = 25 # GAP between the row/col labels and the map hexes

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
        selected_hex = @tile_selector&.hex
        @hexes << @hexes.delete(selected_hex) if @hexes.include?(selected_hex)

        @hexes.map! do |hex|
          h(Hex, hex: hex, round: round, opacity: @opacity)
        end

        children = [render_map]

        if @tile_selector && @tile_selector.hex.tile != @tile_selector.tile
          children << h(TileConfirmation)
        elsif @tile_selector
          tiles = round.upgradeable_tiles(@tile_selector.hex)
          children << h(TileSelector, layout: @layout, tiles: tiles)
        end

        props = {
          style: {
            overflow: 'auto',
            margin: '1rem -1rem',
          },
        }

        h(:div, props, children)
      end

      def render_map
        font_size = 25
        map_x = GAP + font_size
        map_y = GAP + (@layout == :flat ? (font_size / 2) : font_size)

        w_size, h_size = @layout == :flat ? [85, 50] : [50, 85]
        width = (@cols.size * w_size) + GAP
        height = (@rows.size * h_size) + GAP
        props = {
          attrs: {
            id: 'map',
            width: width.to_s,
            height: height.to_s,
          },
        }

        h(:svg, props, [
          h(:g, { attrs: { transform: 'scale(0.5)' } }, [
            h(:g, { attrs: { id: 'map-hexes', transform: "translate(#{map_x} #{map_y})" } }, @hexes),
            h(Axis,
              cols: @cols,
              rows: @rows,
              axes: @game.axes,
              layout: @layout,
              font_size: font_size,
              gap: GAP,
              map_x: map_x,
              map_y: map_y),
          ]),
        ])
      end
    end
  end
end
