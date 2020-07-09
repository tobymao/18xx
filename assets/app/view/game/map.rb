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

      EDGE_LENGTH = 50
      SIDE_TO_SIDE = 87
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
          if @game.special.map_abilities
            @game.special
          else
            @game.round
          end

        step = round.active_step
        # move the selected hex to the back so it renders highest in z space
        selected_hex = @tile_selector&.hex
        @hexes << @hexes.delete(selected_hex) if @hexes.include?(selected_hex)

        @hexes.map! do |hex|
          h(Hex, hex: hex, step: step, opacity: @opacity)
        end

        children = [render_map]

        if @tile_selector
          left = (@tile_selector.x + map_x) * SCALE
          top = (@tile_selector.y + map_y) * SCALE
          selector =
            if @tile_selector.is_a?(Lib::TokenSelector)
              # 1882
              h(TokenSelector)
            elsif @tile_selector.hex.tile != @tile_selector.tile
              h(TileConfirmation)
            else
              # Selecting column A can cause tiles to go off the edge of the map
              distance = TileSelector::DISTANCE + (TileSelector::TILE_SIZE / 2)

              width, height = map_size
              left = distance if (left - distance).negative?
              if (left + distance + TileSelector::DROP_SHADOW_SIZE) >= width
                left = width - TileSelector::DROP_SHADOW_SIZE - distance
              end

              top = distance if (top - distance).negative?
              if (top + distance + TileSelector::DROP_SHADOW_SIZE) >= height
                top = height - TileSelector::DROP_SHADOW_SIZE - distance
              end

              tiles = @game.upgradeable_tiles(@tile_selector.hex)

              h(TileSelector, layout: @layout, tiles: tiles, step: step)
            end

          # Move the position to the middle of the hex
          props = {
           style: {
             position: 'absolute',
             left: "#{left}px",
             top: "#{top}px",
           },
          }
          # This needs to be before the map, so that the relative positioning works
          children.unshift(h(:div, props, [selector]))
        end

        props = {
          style: {
            overflow: 'auto',
            margin: '1rem 0',
            position: 'relative',
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

      def map_size
        if @layout == :flat
          [(@cols.size * 1.5 + 0.5) * EDGE_LENGTH + 2 * GAP,
           (@rows.size / 2 + 0.5) * SIDE_TO_SIDE + 2 * GAP]
        else
          [(@cols.size / 2 + 0.5) * SIDE_TO_SIDE + 2 * GAP,
           (@rows.size * 1.5 + 0.5) * EDGE_LENGTH + 2 * GAP]
        end
      end

      def render_map
        width, height = map_size

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
