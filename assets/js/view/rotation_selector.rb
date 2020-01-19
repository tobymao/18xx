# frozen_string_literal: true

require 'view/actionable'
require 'view/hex'

require 'engine/hex'
require 'engine/tile'

module View
  class RotationSelector < Snabberb::Component
    needs :selected_hex_info, store: true

    def render
      style = {
        position: 'absolute',
        left: @selected_hex_info[:x],
        top: @selected_hex_info[:y],
        'font-size': '20px',
      }

      rotation_style = {
        position: 'absolute',
        cursor: 'pointer',
        transform: 'scale(-1, -1)',
      }

      clockwise = {
        props: { innerHTML: '&#8635' },
        style: {
          **rotation_style,
          left: View::Hex::SIZE - 12,
        },
        on: { click: -> { rotate(true) } }
      }

      counter_clockwise = {
        props: { innerHTML: '&#8634' },
        style: rotation_style,
        on: { click: -> { rotate(false) } },
      }

      h(:div, { style: style }, [
        h(:div, clockwise),
        h(:div, counter_clockwise),
      ])
    end

    def rotate(clockwise)
      @selected_hex_info[:tile].rotate!(clockwise)
      update
    end
  end
end
