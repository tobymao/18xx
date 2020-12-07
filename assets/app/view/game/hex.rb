# frozen_string_literal: true

require 'lib/hex'
require 'lib/tile_selector'
require 'view/game/actionable'
require 'view/game/runnable'
require 'view/game/tile'
require 'view/game/triangular_grid'
require 'view/game/tile_unavailable'

module View
  module Game
    class Hex < Snabberb::Component
      include Actionable
      include Runnable

      SIZE = 100

      LAYOUT = {
        flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
        pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
      }.freeze

      needs :hex
      needs :tile_selector, default: nil, store: true
      needs :role, default: :map
      needs :opacity, default: 1.0
      needs :user, default: nil, store: true

      needs :clickable, default: false
      needs :actions, default: []
      needs :entity, default: nil
      needs :unavailable, default: nil
      needs :show_coords, default: nil
      needs :show_location_names, default: true
      needs :routes, default: []

      def render
        return nil if @hex.empty

        @selected = @hex == @tile_selector&.hex || @selected_route&.last_node&.hex == @hex
        @tile =
          if @selected && @actions.include?('lay_tile') && @tile_selector&.tile
            @tile_selector.tile
          else
            @hex.tile
          end
        children = hex_outline
        if @tile
          children << h(
            Tile,
            tile: @tile,
            show_coords: @show_coords && (@role == :map),
            show_location_names: @show_location_names,
            routes: @routes
          )
        end
        children << h(TriangularGrid) if Lib::Params['grid']
        children << h(TileUnavailable, unavailable: @unavailable, layout: @hex.layout) if @unavailable

        props = {
          key: @hex.id,
          attrs: {
            transform: transform,
            fill: @user&.dig(:settings, @tile&.color) || (Lib::Hex::COLOR[@tile&.color || 'white']),
            stroke: 'black',
          },
        }

        props[:attrs][:opacity] = @opacity if @opacity != 1.0
        props[:attrs][:cursor] = 'pointer' if @clickable

        props[:on] = { click: ->(e) { on_hex_click(e) } }
        props[:attrs]['stroke-width'] = 5 if @selected
        h(:g, props, children)
      end

      def hex_outline
        polygon_props = { attrs: { points: Lib::Hex::POINTS } }

        invisible_edges = @tile.borders.select { |b| b.type.nil? }.map(&:edge) if @tile
        if invisible_edges&.any?
          polygon_props[:attrs][:stroke] = 'none'
          shapes = [h(:polygon, polygon_props)]

          (Engine::Tile::ALL_EDGES - invisible_edges).each do |edge|
            shapes << h(:path, attrs: { d: Lib::Hex::EDGE_PATHS[edge] })
          end

          shapes
        else
          [h(:polygon, polygon_props)]
        end
      end

      def translation
        x, y = coordinates
        "translate(#{x}, #{y})"
      end

      def self.coordinates(hex)
        t_x, t_y = LAYOUT[hex.layout]
        [(t_x * hex.x + SIZE).round(2), (t_y * hex.y + SIZE).round(2)]
      end

      def coordinates
        self.class.coordinates(@hex)
      end

      def transform
        "#{translation}#{@hex.layout == :pointy ? ' rotate(30)' : ''}"
      end

      def on_hex_click
        return if @actions.empty? && @role != :tile_page

        if !@clickable || (@hex == @tile_selector&.hex && !(@tile_selector.respond_to?(:tile) && @tile_selector.tile))
          return store(:tile_selector, nil)
        end

        nodes = @hex.tile.nodes

        if @actions.include?('run_routes')
          touch_node(nodes[0]) if nodes.one?
          return
        end

        case @role
        when :map
          return process_action(Engine::Action::Assign.new(@entity, target: @hex)) if @actions.include?('assign')
          return unless @actions.include?('lay_tile')

          if @selected && (tile = @tile_selector&.tile)
            @tile_selector.rotate! if tile.hex != @hex
          else
            store(:tile_selector, Lib::TileSelector.new(@hex, @tile, coordinates, root, @entity, @role))
          end
        when :tile_page
          store(:tile_selector, Lib::TileSelector.new(@hex, @tile, coordinates, root, @entity, @role))
        when :tile_selector
          @tile_selector.tile = @tile
        end
      end
    end
  end
end
