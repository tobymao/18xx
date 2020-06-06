# frozen_string_literal: true

require 'lib/hex'

module View
  module Part
    class Borders < Snabberb::Component
      needs :tile
      needs :user, default: nil, store: true

      EDGES = {
        0 => {
          x1: Lib::Hex::X_M_R,
          y1: Lib::Hex::Y_B,
          x2: Lib::Hex::X_M_L,
          y2: Lib::Hex::Y_B,
        },
        1 => {
          x1: Lib::Hex::X_M_L,
          y1: Lib::Hex::Y_B,
          x2: Lib::Hex::X_L,
          y2: Lib::Hex::Y_M,
        },
        2 => {
          x1: Lib::Hex::X_L,
          y1: Lib::Hex::Y_M,
          x2: Lib::Hex::X_M_L,
          y2: Lib::Hex::Y_T,
        },
        3 => {
          x1: Lib::Hex::X_M_L,
          y1: Lib::Hex::Y_T,
          x2: Lib::Hex::X_M_R,
          y2: Lib::Hex::Y_T,
        },
        4 => {
          x1: Lib::Hex::X_M_R,
          y1: Lib::Hex::Y_T,
          x2: Lib::Hex::X_R,
          y2: Lib::Hex::Y_M,
        },
        5 => {
          x1: Lib::Hex::X_R,
          y1: Lib::Hex::Y_M,
          x2: Lib::Hex::X_M_R,
          y2: Lib::Hex::Y_B,
        },
      }.freeze

      def render_borders
        @tile.borders.map do |border|
          color = @user&.dig(:settings, @tile&.color) || Lib::Hex::COLOR.fetch(@tile.color)

          h(:line, attrs: {
            **EDGES[border.edge],
            stroke: color,
            'stroke-width': '4',
          })
        end
      end

      def render
        h(:g, render_borders)
      end
    end
  end
end
