# frozen_string_literal: true

require '../lib/storage'
require '../lib/settings'
require 'view/game/axis'
require 'view/game/hex'
require 'view/game/tile_confirmation'
require 'view/game/tile_selector'
require 'view/game/token_selector'

module View
  module Game
    class Map < Snabberb::Component
      include Lib::Settings
      needs :game
      needs :tile_selector, default: nil, store: true
      needs :selected_route, default: nil, store: true
      needs :selected_company, default: nil, store: true
      needs :selected_combos, default: nil, store: true
      needs :opacity, default: nil
      needs :show_starting_map, default: false, store: true
      needs :routes, default: [], store: true
      needs :historical_laid_hexes, default: nil, store: true
      needs :historical_routes, default: [], store: true
      needs :map_zoom, default: nil, store: true

      EDGE_LENGTH = 50
      SIDE_TO_SIDE = 87
      FONT_SIZE = 25
      GAP = 25 # GAP between the row/col labels and the map hexes
      SCALE = 0.5 # Scale for the map

      def render
        return h(:div, []) if (@layout = @game.layout) == :none

        @hexes = @show_starting_map ? @game.clone([]).hexes : @game.hexes.dup
        @cols = @hexes.reject(&:ignore_for_axes).map(&:x).uniq.sort.map(&:next)
        @rows = @hexes.reject(&:ignore_for_axes).map(&:y).uniq.sort.map(&:next)
        @start_pos = [@cols.first, @rows.first]

        @scale = SCALE * map_zoom

        step = @game.round.active_step(@selected_company)
        current_entity = @selected_company || step&.current_entity
        combo_entities = (@selected_combos || []).map { |id| @game.company_by_id(id) }
        entity_or_entities = combo_entities.empty? ? current_entity : [current_entity, *combo_entities]
        actions = step&.actions(current_entity) || []

        unless (laid_hexes = @historical_laid_hexes)
          laid_hexes = @game.round.respond_to?(:laid_hexes) ? @game.round.laid_hexes : []
        end
        selected_hex = @tile_selector&.hex
        # Move the selected hex to the back so they render highest in z space
        @hexes << @hexes.delete(selected_hex) if @hexes.include?(selected_hex)

        routes = @routes
        routes = @historical_routes if routes.none?

        @hexes.map! do |hex|
          clickable = @show_starting_map ? false : step&.available_hex(entity_or_entities, hex)
          opacity = clickable ? 1.0 : 0.5
          h(
            Hex,
            hex: hex,
            opacity: @show_starting_map ? 1.0 : (@opacity || opacity),
            entity: current_entity,
            clickable: clickable,
            actions: actions,
            routes: routes,
            start_pos: @start_pos,
            highlight: laid_hexes.include?(hex),
          )
        end
        @hexes.compact!

        children = [render_map, h(MapZoom, map_zoom: map_zoom)]

        if current_entity && @tile_selector
          left = (@tile_selector.x + map_x) * @scale
          top = (@tile_selector.y + map_y) * @scale
          selector =
            if @tile_selector.is_a?(Lib::TokenSelector)
              # 1882
              h(TokenSelector, zoom: map_zoom)
            elsif @tile_selector.role != :map
              # Tile selector not for the map
            elsif @tile_selector.hex.tile != @tile_selector.tile
              h(TileConfirmation, zoom: map_zoom)
            else
              tiles = step.upgradeable_tiles(entity_or_entities, @tile_selector.hex)
              all_upgrades = @game.all_potential_upgrades(@tile_selector.hex.tile, selected_company: @selected_company)
              phase_colors = step.potential_tile_colors(current_entity, @tile_selector.hex)
              select_tiles = all_upgrades.map do |tile|
                real_tile = tiles.find { |t| t.name == tile.name }
                if real_tile
                  tiles.delete(real_tile)
                  [real_tile, nil]
                elsif !@game.tile_valid_for_phase?(tile, hex: @tile_selector.hex, phase_color_cache: phase_colors)
                  [tile, 'Later Phase']
                elsif @game.tiles.none? { |t| t.name == tile.name }
                  [tile, 'None Left']
                end
              end.compact

              # Add tiles that aren't part of all_upgrades (Mitsubishi ferry)
              select_tiles.append(*tiles.map { |t| [t, nil] })

              return h(:div) if select_tiles.empty?

              distance = TileSelector::DISTANCE * map_zoom
              width, height = map_size
              ts_ds = [TileSelector::DROP_SHADOW_SIZE - 5, 0].max # ignore up to 5px of ds (< 2vmin padding of #app)
              left_col = left < distance
              right_col = width - left < distance + ts_ds
              top_row = top < distance
              bottom_row = height - top < distance + ts_ds

              h(TileSelector, layout: @layout, tiles: select_tiles, actions: actions, zoom: map_zoom, top_row: top_row,
                              left_col: left_col, right_col: right_col, bottom_row: bottom_row)
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
            margin: '0.5rem 0 0 0',
            position: 'relative',
          },
        }

        map_elements = [h(:div, props, children), h(MapControls)]
        map_elements << render_legend if @game.show_map_legend?

        h(:div, { style: { marginBottom: '1rem' } }, map_elements)
      end

      def map_x
        GAP + FONT_SIZE
      end

      def map_y
        GAP + (@layout == :flat ? (FONT_SIZE / 2) : FONT_SIZE)
      end

      def map_size
        if @layout == :flat
          [((((@cols.size * 1.5) + 0.5) * EDGE_LENGTH) + (2 * GAP)) * map_zoom,
           ((((@rows.size / 2) + 0.5) * SIDE_TO_SIDE) + (2 * GAP)) * map_zoom]
        else
          [(((((@cols.size / 2) + 0.5) * SIDE_TO_SIDE) + (2 * GAP)) + 1) * map_zoom,
           ((((@rows.size * 1.5) + 0.5) * EDGE_LENGTH) + (2 * GAP)) * map_zoom]
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
          h(:g, { attrs: { transform: "scale(#{@scale})" } }, [
            h(:g, { attrs: { id: 'map-hexes', transform: "translate(#{map_x} #{map_y})" } }, @hexes),
            h(Axis,
              cols: @cols,
              rows: @rows,
              axes: @game.axes,
              layout: @layout,
              font_size: FONT_SIZE,
              gap: GAP,
              map_x: map_x,
              map_y: map_y,
              start_pos: @start_pos),
          ]),
        ])
      end

      def map_zoom
        Lib::Storage['map_zoom'] || 1
      end

      def render_legend
        table_props, header, *chart = @game.map_legend(
          color_for(:font),
          color_for(:yellow),
          color_for(:green),
          color_for(:brown),
          color_for(:gray)
        )

        head = header.map do |cell|
          item = cell[:text] || h(:image, { attrs: { href: cell[:image] } })
          if cell[:props]
            h(:th, cell[:props], item)
          else
            h(:th, item)
          end
        end

        rows = chart.map do |r|
          columns = r.map do |cell|
            item = cell[:text] || [h(:img, { attrs: { src: cell[:image], height: cell[:image_height] } })]
            if cell[:props]
              h(:td, cell[:props], item)
            else
              h(:td, item)
            end
          end
          h(:tr, columns)
        end

        h(:table, table_props, [
          h(:thead, [
            h(:tr, head),
          ]),
          h(:tbody, rows),
        ])
      end
    end
  end
end
