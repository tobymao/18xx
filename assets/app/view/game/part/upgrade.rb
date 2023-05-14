# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Upgrade < Base
        include SmallItem

        needs :cost
        needs :terrains, default: []
        needs :size, default: nil

        P_CENTER = {
          region_weights: CENTER,
          x: 0,
          y: 0,
        }.freeze

        P_TOP_RIGHT_CORNER = {
          region_weights: [3, 4],
          x: 30,
          y: -60,
        }.freeze

        P_BOTTOM_RIGHT_CORNER = {
          region_weights: [22, 23],
          x: 30,
          y: 60,
        }.freeze

        P_BOTTOM_LEFT_CORNER = {
          region_weights: [19, 20],
          x: -30,
          y: 60,
        }.freeze

        P_EDGE2 = {
          region_weights: [0, 5, 6],
          x: -50,
          y: -45,
        }.freeze
        PP_EDGE2 = {
          region_weights: [0, 5, 6],
          x: -35,
          y: -55,
        }.freeze

        P_RIGHT_CORNER = {
          region_weights: [11, 18],
          x: 70,
          y: 0,
        }.freeze

        P_LEFT_CORNER = {
          region_weights: [5, 12],
          x: -70,
          y: 0,
        }.freeze

        SIZE = 20
        WATER_PATH = 'M -15 -7 Q -7.5 -15, 0 -7 S 7.5 1, 15 -7M -15 -2  Q -7.5 -10, 0 -2  S 7.5 6, 15 -2'
        TRIANGLE_PATH = '0,20 10,0 20,20'

        def preferred_render_locations
          if layout == :flat
            [
              P_CENTER,
              P_TOP_RIGHT_CORNER,
              P_EDGE2,
              P_BOTTOM_LEFT_CORNER,
              P_RIGHT_CORNER,
              P_LEFT_CORNER,
              P_BOTTOM_RIGHT_CORNER,
            ]
          else
            [
              P_CENTER,
              PP_TOP_RIGHT_CORNER,
              PP_EDGE2,
              PP_BOTTOM_LEFT_CORNER,
              PP_RIGHT_CORNER,
              PP_LEFT_CORNER,
              PP_BOTTOM_RIGHT_CORNER,
            ]
          end
        end

        def parts_for_loc
          @terrains
        end

        def render_part
          cost = h('text.number', { attrs: { fill: 'black' } }, @cost)

          delta_x = -(size / 2)

          terrain = @terrains.map.with_index do |t, index|
            delta_y = 5 + (size * index)
            {
              mountain: mountain(delta_x: delta_x, delta_y: delta_y),
              water: water(delta_x: delta_x, delta_y: delta_y),
              swamp: svg(delta_x: delta_x, delta_y: delta_y, icon: 'swamp'),
              desert: svg(delta_x: delta_x, delta_y: delta_y, icon: 'cactus'),
              lake: svg(delta_x: delta_x, delta_y: delta_y, icon: 'lake'),
              river: svg(delta_x: delta_x, delta_y: delta_y, icon: 'river'),
              hill: svg(delta_x: delta_x, delta_y: delta_y, icon: 'hill'),
              cow_skull: svg(delta_x: delta_x, delta_y: delta_y, icon: 'cow_skull'),
              wall: svg(delta_x: delta_x, delta_y: delta_y, icon: 'wall'),
              forest: svg(delta_x: delta_x, delta_y: delta_y, icon: 'tree'),
            }[t]
          end

          children = [cost] + terrain

          h(:g, { attrs: { transform: rotation_for_layout } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
        end

        def mountain(delta_x: 0, delta_y: 0)
          h(:polygon, attrs: {
              transform: "translate(#{delta_x} #{delta_y})",
              fill: '#cb7745',
              points: TRIANGLE_PATH,
            })
        end

        def water(delta_x: 0, delta_y: 0)
          h(:g, { attrs: { transform: "translate(#{10 + delta_x} #{12 + delta_y}) scale(0.7)" } }, [
            h('path.tile__water', attrs: { d: WATER_PATH }),
          ])
        end

        def svg(icon:, delta_x: 0, delta_y: 0)
          h(
            :image, attrs: {
              href: "/icons/#{icon}.svg",
              x: delta_x,
              y: delta_y,
              height: size,
              width: size,
            },
          )
        end

        def size
          @size ||= SIZE
        end
      end
    end
  end
end
