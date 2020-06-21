# frozen_string_literal: true

require 'lib/hex'
require 'lib/tile_selector'
require 'view/game/runnable'
require 'view/game/tile'
require 'view/game/triangular_grid'

module View
  module Game
    class Hex < Snabberb::Component
      include Runnable

      SIZE = 100

      LAYOUT = {
        flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
        pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
      }.freeze

      NON_TRANSPARENT_ROLES = %i[tile_selector tile_page].freeze

      needs :hex
      needs :round, default: nil
      needs :tile_selector, default: nil, store: true
      needs :role, default: :map
      needs :opacity, default: nil
      needs :user, default: nil, store: true

      def render
        @selected = @hex == @tile_selector&.hex || @selected_route&.last_node&.hex == @hex
        @tile = @selected && @round.can_lay_track? && @tile_selector&.tile ? @tile_selector.tile : @hex.tile

        children = [h(:polygon, attrs: { points: Lib::Hex::POINTS })]
        children << h(Tile, tile: @tile) if @tile
        children << h(TriangularGrid) if Lib::Params['grid']

        opaque = true
        clickable = @role == :tile_selector

        case @round
        when Engine::Round::Operating
          case @round.step
          when :track, :token_or_track
            opaque = @round.connected_hexes[@hex]
            clickable ||= opaque
          when :token, :route, :home_token, :reposition_token
            opaque = @round.reachable_hexes[@hex]
            clickable ||= opaque
          end
        when Engine::Round::Special
          opaque = @round.connected_hexes[@hex]
          clickable ||= opaque
        end

        props = {
          attrs: {
            transform: transform,
            fill: @user&.dig(:settings, @tile&.color) || (Lib::Hex::COLOR[@tile&.color || 'white']),
            stroke: 'black',
          },
        }

        opacity_level = opacity(opaque)
        props[:attrs][:opacity] = opacity_level if opacity_level != 1.0
        props[:attrs][:cursor] = 'pointer' if clickable

        props[:on] = { click: ->(e) { on_hex_click(e) } } if clickable
        props[:attrs]['stroke-width'] = 5 if @selected
        h(:g, props, children)
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
        nodes = @hex.tile.nodes

        if @round&.can_run_routes?
          touch_node(nodes[0]) if nodes.one?
          return
        end

        case @role
        when :map
          return unless @round&.can_lay_track?

          if @selected && (tile = @tile_selector&.tile)
            @tile_selector.rotate! if tile.hex != @hex
          else
            store(:tile_selector, Lib::TileSelector.new(@hex, @tile, coordinates, root, @round.current_entity))
          end
        when :tile_selector
          @tile_selector.tile = @tile
        end
      end

      def opacity(opaque)
        return @opacity if @opacity
        return 1.0 if NON_TRANSPARENT_ROLES.include?(@role)

        opaque ? 1.0 : 0.5
      end
    end
  end
end
