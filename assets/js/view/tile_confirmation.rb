# frozen_string_literal: true

module View
  class TileConfirmation < Snabberb::Component
    needs :tile_selector, store: true

    def render
      style = {
        position: 'absolute',
        left: @tile_selector.x,
        top: @tile_selector.y,
        'font-size': '20px',
      }

      back = {
        props: { innerHTML: '🔙' },
        style: {
          position: 'absolute',
          cursor: 'pointer',
          left: '55px',
        },
        on: { click: -> { @tile_selector.tile = nil } },
      }

      delete = {
        props: { innerHTML: '⌫' },
        style: {
          position: 'absolute',
          cursor: 'pointer',
          left: '20px',
        },
        on: { click: -> { store(:tile_selector, nil) } },
      }

      h(:div, { style: style }, [
        h(:div, back),
        h(:div, delete),
      ])
    end
  end
end
