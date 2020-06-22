# frozen_string_literal: true

require 'view/game/axis'
require 'view/game/hex'
require 'view/game/tile_confirmation'
require 'view/game/tile_selector'
require 'view/game/token_selector'

module View
  module Game
    class Map < Snabberb::Component
      needs :game
      needs :tile_selector, default: nil, store: true
      needs :selected_route, default: nil, store: true
      needs :selected_company, default: nil, store: true
      needs :opacity, default: nil

      FONT_SIZE = 25
      GAP = 25 # GAP between the row/col labels and the map hexes
      SCALE = 0.5 # Scale for the map

      def render
        @hexes = @game.hexes.dup
        @cols = @hexes.map(&:x).uniq.sort.map(&:next)
        @rows = @hexes.map(&:y).uniq.sort.map(&:next)
        @layout = @game.layout

        @game.special.current_entity = @selected_company

        round =
          if @game.special.tile_laying_ability
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

        if @tile_selector
          left = (@tile_selector.x + map_x) * SCALE

          selector =
            if @tile_selector.is_a?(Lib::TokenSelector)
              # 1882
              h(TokenSelector)
            elsif @tile_selector.hex.tile != @tile_selector.tile
              h(TileConfirmation)
            else
              # Selecting column A can cause tiles to go off the edge of the map
              distance = TileSelector::DISTANCE + (TileSelector::TILE_SIZE / 2)
              left = distance if (left - distance).negative?
              tiles = round.upgradeable_tiles(@tile_selector.hex)
              h(TileSelector, layout: @layout, tiles: tiles)
            end

          # Move the position to the middle of the hex
          props = {
           style: {
             position: 'relative',
             left: "#{left}px",
             top: "#{(@tile_selector.y + map_y) * SCALE}px",
           },
          }
          # This needs to be before the map, so that the relative positioning works
          children.unshift(h(:div, props, [selector]))
        end

        props = {
          style: {
            overflow: 'auto',
            margin: '1rem -1rem',
          },
        }

        h(:div, props, children)
      end

      def map_x
        GAP + FONT_SIZE
      end

      def map_y
        GAP + (@layout == :flat ? (FONT_SIZE / 2) : FONT_SIZE)
      end

      def render_map
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
          h(:g, { attrs: { transform: "scale(#{SCALE})" } }, [
            h(:g, { attrs: { id: 'map-hexes', transform: "translate(#{map_x} #{map_y})" } }, @hexes),
            h(Axis,
              cols: @cols,
              rows: @rows,
              axes: @game.axes,
              layout: @layout,
              font_size: FONT_SIZE,
              gap: GAP,
              map_x: map_x,
              map_y: map_y),
          ]),
        ])
      end
    end
  end
end
