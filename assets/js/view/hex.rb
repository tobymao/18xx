# frozen_string_literal: true

require 'view/actionable'
require 'view/tile'

require 'engine/tile'
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

    needs :hex
    needs :selected_hex_info, default: nil, store: true
    needs :role, default: :map

    def render
      children = [h(:polygon, attrs: { points: self.class::POINTS })]
      tile = @hex.tile
      children << h(Tile, tile: tile) if tile
      @selected = @selected_hex_info && @selected_hex_info[:hex] == @hex

      props = {
        attrs: {
          transform: transform,
          fill: tile&.color || 'white',
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
      if @selected
        store(:selected_hex_info, nil)
        return
      end

      case @role
      when :map
        rect = event.JS['target'].JS.getBoundingClientRect

        store(
          :selected_hex_info,
          hex: @hex,
          tile: @hex.tile,
          x: rect.JS['x'],
          y: rect.JS['y'],
        )
      when :tile_selector
        @selected_hex_info[:tile] = @hex.tile

        action = Engine::Action::LayTile.new(
          @game.round.current_entity,
          @hex.tile,
          @selected_hex_info[:hex],
        )
        process_action(action)
      end
    end
  end
end
