# frozen_string_literal: true

require 'lib/tile_selector'
require 'view/actionable'
require 'view/tile'
require 'engine/action/lay_tile'

module View
  class Hex < Snabberb::Component
    include Actionable

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
    }.freeze

    needs :hex
    needs :tile_selector, default: nil, store: true
    needs :role, default: :map

    def render
      children = [h(:polygon, attrs: { points: self.class::POINTS })]

      @selected = @hex == @tile_selector&.hex
      @tile = @selected && @tile_selector.tile ? @tile_selector.tile : @hex.tile

      children << h(Tile, tile: @tile) if @tile

      props = {
        attrs: {
          transform: transform,
          fill: COLOR.fetch(@tile&.color, 'white'),
          stroke: 'black',
        },
        on: { click: ->(e) { on_hex_click(e) } },
      }

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
      `console.log(#{event})`
      return @tile_selector.rotate! if @selected && @tile_selector.tile

      case @role
      when :map
        if !@selected && @tile_selector&.tile
          action = Engine::Action::LayTile.new(
            @game.current_entity,
            @tile_selector.tile,
            @tile_selector.hex,
            @tile_selector.tile.rotation,
          )
          process_action(action)
          store(:tile_selector, nil)
        else
          store(:tile_selector, Lib::TileSelector.new(@hex, @tile, event, root))
        end
      when :tile_selector
        @tile_selector.tile = @tile
      end
    end
  end
end
