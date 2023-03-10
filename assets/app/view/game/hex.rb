# frozen_string_literal: true

require 'lib/hex'
require 'lib/settings'
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
      include Lib::Settings

      SIZE = 100

      FRAME_COLOR_STROKE_WIDTH = 10
      FRAME_COLOR_POINTS = Lib::Hex.points(scale: 1 - (((FRAME_COLOR_STROKE_WIDTH + 1) / 2) / Lib::Hex::Y_B)).freeze

      HIGHLIGHT_STROKE_WIDTH = 6
      HIGHLIGHT_POINTS = Lib::Hex.points(scale: 1 - (((HIGHLIGHT_STROKE_WIDTH + 1) / 2) / Lib::Hex::Y_B)).freeze

      LAYOUT = {
        flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
        pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
      }.freeze

      needs :hex
      needs :tile_selector, default: nil, store: true
      needs :role, default: :map
      needs :opacity, default: nil
      needs :user, default: nil, store: true

      needs :clickable, default: false
      needs :actions, default: []
      needs :entity, default: nil
      needs :unavailable, default: nil
      needs :routes, default: []
      needs :start_pos, default: [1, 1]
      needs :highlight, default: false

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
        if (color = @tile&.frame&.color)
          attrs = {
            stroke: color,
            'stroke-width': FRAME_COLOR_STROKE_WIDTH,
            points: FRAME_COLOR_POINTS,
          }
          children << h(:polygon, attrs: attrs)

          if (color2 = @tile&.frame&.color2)
            attrs = {
              stroke: color2,
              'stroke-width': FRAME_COLOR_STROKE_WIDTH,
              pathLength: 576,
              'stroke-dasharray': 32,
              'stroke-dashoffset': 16,
              'fill-opacity': 0,
              points: FRAME_COLOR_POINTS,
            }
            children << h(:polygon, attrs: attrs)
          end
        end
        children << hex_highlight if @highlight

        if (color = @tile&.stripes&.color)
          Lib::Hex.stripe_points.each do |stripe|
            attrs = {
              fill: Lib::Hex::COLOR[color],
              points: stripe,
            }
            children << h(:polygon, attrs: attrs)
          end
        end

        if @tile
          children << h(
            Tile,
            tile: @tile,
            show_coords: setting_for(:show_coords, @game) && (@role == :map),
            routes: @routes,
            game: @game
          )
        end
        children << h(TriangularGrid) if Lib::Params['grid']
        children << h(TileUnavailable, unavailable: @unavailable, layout: @hex.layout) if @unavailable

        props = {
          key: @hex.id,
          attrs: {
            transform: transform,
            fill: color_for(@tile&.color) || (Lib::Hex::COLOR[@tile&.color || 'white']),
            stroke: 'black',
          },
        }

        props[:attrs][:opacity] = @opacity if @opacity
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

      def hex_highlight
        polygon_props = {
          attrs: {
            points: HIGHLIGHT_POINTS,
            'fill-opacity': 0,
            pathLength: 576, # 6*96, total length of polygon border => easier dasharray arithmetic
            'stroke-dasharray': 16,
            'stroke-dashoffset': 8,
            'stroke-width': HIGHLIGHT_STROKE_WIDTH,
          },
        }
        if (color = @tile&.frame&.color)
          polygon_props[:attrs]['stroke'] = contrast_on(color)
        end

        h(:polygon, polygon_props)
      end

      def translation
        x, y = coordinates
        "translate(#{x}, #{y})"
      end

      def self.coordinates(hex, start_pos = [1, 1])
        t_x, t_y = LAYOUT[hex.layout]
        [((t_x * (hex.x - start_pos[0] + 1)) + SIZE).round(2), ((t_y * (hex.y - start_pos[1] + 1)) + SIZE).round(2)]
      end

      def coordinates
        self.class.coordinates(@hex, @start_pos)
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
          disambiguate_node(nodes) if nodes.count(&:offboard?) > 1
          return
        end

        case @role
        when :map
          return process_action(Engine::Action::Assign.new(@entity, target: @hex)) if @actions.include?('assign')

          step = @game.round.active_step
          if @actions.include?('remove_hex_token') && @hex.tokens.find { |t| t.corporation == @entity }
            return process_action(Engine::Action::RemoveHexToken.new(
              @entity,
              hex: @hex,
            ))
          end
          if @actions.include?('hex_token')
            return if step.available_tokens(@entity).empty?

            next_token = step.available_tokens(@entity)[0].type
            return process_action(Engine::Action::HexToken.new(
              @entity,
              hex: @hex,
              cost: step.token_cost_override(@entity, @hex, nil, @entity.find_token_by_type(next_token&.to_sym)),
              token_type: next_token
            ))
          end
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
