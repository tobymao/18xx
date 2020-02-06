# frozen_string_literal: true

require 'view/actionable'

module View
  class TileConfirmation < Snabberb::Component
    include Actionable

    needs :tile_selector, store: true

    def render
      style = {
        position: 'absolute',
        left: @tile_selector.x,
        top: @tile_selector.y,
      }

      confirm = {
        props: { innerHTML: '☑' },
        style: {
          position: 'absolute',
          cursor: 'pointer',
          left: '22px',
          top: '-8px',
          'font-size': '35px',
        },
        on: { click: -> { lay_tile } },
      }

      delete = {
        props: { innerHTML: '⌫' },
        style: {
          position: 'absolute',
          cursor: 'pointer',
          left: '52px',
          'font-size': '20px',
        },
        on: { click: -> { store(:tile_selector, nil) } },
      }

      h(:div, { style: style }, [
        h(:div, confirm),
        h(:div, delete),
      ])
    end

    def lay_tile
      action = Engine::Action::LayTile.new(
        @game.current_entity,
        @tile_selector.tile,
        @tile_selector.hex,
        @tile_selector.tile.rotation,
      )
      process_action(action)
      store(:tile_selector, nil)
    end
  end
end
