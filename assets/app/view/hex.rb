# frozen_string_literal: true

require_tree 'engine'
require 'lib/hex'
require 'lib/tile_selector'
require 'view/runnable'
require 'view/tile'
require 'view/triangular_grid'

module View
  class Hex < Snabberb::Component
    include Runnable

    SIZE = 100

    LAYOUT = {
      flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
      pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
    }.freeze

    COLOR = {
      white: '#EAE0C8',
      yellow: '#fde900',
      green: '#71bf44',
      brown: '#cb7745',
      gray: '#bcbdc0',
      red: '#ec232a',
      blue: '#00f',
    }.freeze

    NON_TRANSPARENT_ROLES = %i[tile_selector tile_page].freeze

    needs :hex
    needs :round, default: nil
    needs :tile_selector, default: nil, store: true
    needs :role, default: :map
    needs :opacity, default: nil

    def render
      children = [h(:polygon, attrs: { points: Lib::Hex::POINTS })]

      @selected = @hex == @tile_selector&.hex || @selected_route&.last_node&.hex == @hex
      @tile = @selected && @round.can_lay_track? && @tile_selector&.tile ? @tile_selector.tile : @hex.tile

      children << h(Tile, tile: @tile) if @tile
      children << h(View::TriangularGrid) if Lib::Params['grid']

      opaque = true
      clickable = @role == :tile_selector

      case @round
      when Engine::Round::Operating
        case @round.step
        when :track
          opaque = @round.connected_hexes[@hex]
          clickable ||= opaque
        when :token, :route
          opaque = @round.reachable_hexes[@hex]
          clickable ||= opaque
        end
      when Engine::Round::Special
        opaque = @round.connected_hexes[@hex]
        clickable ||= opaque
      end

      props = {
        attrs: {
          id: "hex-#{@hex.coordinates}",
          transform: transform,
          fill: COLOR.fetch(@tile&.color, 'white'),
          stroke: 'black',
          opacity: opacity(opaque),
          cursor: clickable ? 'pointer' : nil,
       },
      }

      props[:on] = { click: ->(e) { on_hex_click(e) } } if clickable
      props[:attrs]['stroke-width'] = 5 if @selected

      h(:g, props, children)
    end

    def translation
      t_x, t_y = LAYOUT[@hex.layout]
      "translate(#{t_x * @hex.x + SIZE}, #{t_y * @hex.y + SIZE})"
    end

    def transform
      "#{translation}#{@hex.layout == :pointy ? ' rotate(30)' : ''}"
    end

    def on_hex_click(event)
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
          store(:tile_selector, Lib::TileSelector.new(@hex, @tile, event, root, @round.current_entity))
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
