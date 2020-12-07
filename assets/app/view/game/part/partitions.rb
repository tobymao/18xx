# frozen_string_literal: true

require 'lib/color'
require 'lib/hex'
require 'lib/settings'
require 'view/game/part/base'

module View
  module Game
    module Part
      class Partitions < Base
        include Lib::Color
        include Lib::Settings

        needs :tile
        needs :region_use, default: nil
        needs :user, default: nil, store: true

        VERTICES = {
          -1 => [0, 0],
          0 => [Lib::Hex::X_M_R, Lib::Hex::Y_B],
          1 => [Lib::Hex::X_M_L, Lib::Hex::Y_B],
          2 => [Lib::Hex::X_L, Lib::Hex::Y_M],
          3 => [Lib::Hex::X_M_L, Lib::Hex::Y_T],
          4 => [Lib::Hex::X_M_R, Lib::Hex::Y_T],
          5 => [Lib::Hex::X_R, Lib::Hex::Y_M],
        }.freeze

        COEFFICIENT = 0.8

        def color(partition)
          color =
            case partition.type
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

        def convex_combination(x, y)
          [x, y].transpose.map { |xi, yi| COEFFICIENT * xi + (1 - COEFFICIENT) * yi }
        end

        def render_part
          children = []

          @tile.partitions.each do |partition|
            next unless partition.blockers.any? { |b| b.abilities(:blocks_crossing_partition)&.blocks?(partition.type) }

            a_control = VERTICES[(partition.a + partition.a_sign) % 6]
            vertex_a = convex_combination(VERTICES[partition.a], a_control)
            b_control = VERTICES[(partition.b + partition.b_sign) % 6]
            vertex_b = convex_combination(VERTICES[partition.b], b_control)

            da = if partition.a_sign.nonzero?
                   VERTICES[partition.a].map { |x| x * (1 - (1 - COEFFICIENT) * 2) } # cos(30) = 1/2
                 else
                   convex_combination(vertex_a, vertex_b)
                 end.join(' ')

            db = if partition.b_sign.nonzero?
                   VERTICES[partition.b].map { |x| x * (1 - (1 - COEFFICIENT) * 2) } # cos(30) = 1/2
                 else
                   convex_combination(vertex_b, vertex_a)
                 end.join(' ')

            magnet_str = ''
            if partition.magnet
              magnet = VERTICES[partition.magnet].map { |x| x * 0.5 }
              magnet_control = [vertex_a, vertex_b, magnet].transpose.map { |a, b, m| m - (b - a) * 2 / 7 }
              magnet_str = ", #{magnet_control.join(' ')}, #{magnet.join(' ')} S"
            end

            d = "M #{vertex_a.join(' ')} C #{da}#{magnet_str} #{db}, #{vertex_b.join(' ')}"

            children << h(:path, attrs: {
              d: d,
              stroke: color(partition),
              'stroke-width': '5',
            })
          end

          h(:g, children)
        end
      end
    end
  end
end
