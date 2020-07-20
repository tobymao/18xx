# frozen_string_literal: true

require 'lib/color'
require 'lib/hex'
require 'lib/settings'
require 'view/game/part/base'

module View
  module Game
    module Part
      class Borders < Base
        include Lib::Color
        include Lib::Settings

        needs :tile
        needs :region_use, default: nil
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

        def color(border)
          color =
            case border.type
            when nil
              @tile.color
            when :mountain
              :brown
            when :water
              :blue
            when :impassable
              :red
            end

          setting_for(color)
        end

        def render_cost(border)
          edges = EDGES[border.edge]

          x = [edges[:x1], edges[:x2]].sum / 2.0
          y = [edges[:y1], edges[:y2]].sum / 2.0

          stroke_color = contrast_on(color(border))
          text_props = {
            attrs: {
              stroke: stroke_color,
              fill: stroke_color,
              'dominant-baseline': 'central',
              transform: 'translate(0 1)',
            },
          }

          h(:g, { attrs: { transform: "translate(#{x} #{y}), #{rotation_for_layout}" } }, [
            h(:circle, attrs: { stroke: 'none', fill: color(border), r: '18' }),
            h('text.tile__text.number', text_props, border.cost.to_s),
          ])
        end

        def render
          children = []

          @tile.borders.each do |border|
            children << h(:line, attrs: {
              **EDGES[border.edge],
              stroke: color(border),
              'stroke-width': '8',
            })
            children << render_cost(border) if border.cost
          end

          h(:g, children)
        end
      end
    end
  end
end
