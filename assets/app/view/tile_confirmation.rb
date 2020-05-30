# frozen_string_literal: true

require 'view/actionable'

module View
  class TileConfirmation < Snabberb::Component
    include Actionable

    needs :selected_company, store: true, default: nil
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
          left: '75px',
          top: '40px',
          'font-size': '35px',
        },
        on: { click: -> { lay_tile } },
      }

      delete = {
        props: { innerHTML: '⌫' },
        style: {
          position: 'absolute',
          cursor: 'pointer',
          left: '103px',
          top: '44px',
          'font-size': '35px',
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
        @tile_selector.entity,
        @tile_selector.tile,
        @tile_selector.hex,
        @tile_selector.tile.rotation,
      )
      store(:tile_selector, nil, skip: true)
      store(:selected_company, nil, skip: true)
      process_action(action)
    end
  end
end
