# frozen_string_literal: true

require 'lib/tile_selector'
require 'view/tile'
require 'view/triangular_grid'

require 'engine/action/lay_tile'
require 'engine/route'

module View
  class Hex < Snabberb::Component
    SIZE = 100
    POINTS = '100,0 50,-87 -50,-87 -100,-0 -50,87 50,87'
    LAYOUT = {
      flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
      pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
    }.freeze

    COLOR = {
      white: '#fff',
      yellow: '#fde900',
      green: '#71bf44',
      brown: '#cb7745',
      gray: '#bcbdc0',
      red: '#ec232a',
    }.freeze

    needs :hex
    needs :round, default: nil
    needs :selected_route, default: nil, store: true
    needs :tile_selector, default: nil, store: true
    needs :show_grid, default: false, store: true
    needs :role, default: :map

    def render
      children = [h(:polygon, attrs: { points: self.class::POINTS })]

      @selected = @hex == @tile_selector&.hex
      @tile = @selected && @tile_selector.tile ? @tile_selector.tile : @hex.tile

      children << h(Tile, tile: @tile) if @tile
      children << h(View::TriangularGrid) if @show_grid
      layable = @round.layable_hexes.key?(@hex) if @round.respond_to?(:layable_hexes)
      clickable = layable || @role == :tile_selector

      props = {
        attrs: {
          id: "hex-#{@hex.coordinates}",
          transform: transform,
          fill: COLOR.fetch(@tile&.color, 'white'),
          stroke: 'black',
          opacity: layable || %i[tile_selector tile_page].include?(@role) ? 1.0 : 0.3,
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
      if @selected_route
        @selected_route.add_hex(@hex)
        store(:selected_route, @selected_route)
        return
      end

      return @tile_selector.rotate! if @selected && @tile_selector.tile

      case @role
      when :map
        store(
          :tile_selector,
          Lib::TileSelector.new(@hex, @tile, event, root, @round.current_entity),
        )
      when :tile_selector
        @tile_selector.tile = @tile
      end
    end
  end
end
