# frozen_string_literal: true

require 'view/actionable'
require 'view/hex'

require 'engine/action/lay_tile'
require 'engine/hex'
require 'engine/tile'

module View
  class TileConfirmation < Snabberb::Component
    include Actionable

    needs :selected_hex_info, store: true

    def render
      style = {
        position: 'absolute',
        left: @selected_hex_info[:x],
        top: @selected_hex_info[:y],
        'font-size': '20px',
      }

      back = {
        props: { innerHTML: '🔙' },
        style: {
          position: 'absolute',
          cursor: 'pointer',
          left: '55px',
        },
        on: {
          click: lambda do
            @selected_hex_info[:tile] = nil
            rollback
          end
        }
      }

      delete = {
        props: { innerHTML: '⌫' },
        style: {
          position: 'absolute',
          cursor: 'pointer',
          left: '20px',
        },
        on: {
          click: lambda do
            store(:selected_hex_info, nil)
            rollback
          end
        },
      }

      h(:div, { style: style }, [
        h(:div, back),
        h(:div, delete),
      ])
    end
  end
end
