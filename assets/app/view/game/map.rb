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

        step = @game.round.active_step(@selected_company)
        current_entity = @selected_company || step&.current_entity
        actions = step&.actions(current_entity) || []
        # move the selected hex to the back so it renders highest in z space
        selected_hex = @tile_selector&.hex
        @hexes << @hexes.delete(selected_hex) if @hexes.include?(selected_hex)

        @hexes.map! do |hex|
          clickable = step&.available_hex(current_entity, hex)
          opacity = clickable ? 1.0 : 0.5
          h(
            Hex,
            hex: hex,
            opacity: @opacity || opacity,
            entity: current_entity,
            clickable: clickable,
            actions: actions,
          )
        end

        children = [render_map]

        if current_entity && @tile_selector
          left = (@tile_selector.x + map_x) * SCALE
          top = (@tile_selector.y + map_y) * SCALE
          selector =
            if @tile_selector.is_a?(Lib::TokenSelector)
              # 1882
              h(TokenSelector)
            elsif @tile_selector.role != :map
              # Tile selector not for the map
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

              tiles = step.upgradeable_tiles(current_entity, @tile_selector.hex)
              all_upgrades = @game.all_potential_upgrades(@tile_selector.hex.tile)

              select_tiles = all_upgrades.map do |tile|
                real_tile = tiles.find { |t| t.name == tile.name }
                if real_tile
                  [real_tile, nil]
                elsif !@game.phase.tiles.include?(tile.color)
                  [tile, 'Later Phase']
                elsif @game.tiles.none? { |t| t.name == tile.name }
                  [tile, 'None Left']
                end
              end.compact

              h(TileSelector, layout: @layout, tiles: select_tiles, actions: actions)
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
