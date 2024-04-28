# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'
require 'lib/settings'

module View
  module Game
    module Part
      class Assignments < Base
        include SmallItem
        include Lib::Settings

        needs :game, default: nil, store: true
        ICON_RADIUS = 20
        DELTA = (ICON_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :pointy
            case @assignments_to_show&.size
            when 1
              POINTY_SMALL_ITEM_LOCATIONS
            when 2
              POINTY_WIDE_ITEM_LOCATIONS + POINTY_TALL_ITEM_LOCATIONS + POINTY_WIDER_ITEM_LOCATIONS
            else
              POINTY_WIDE_ITEM_LOCATIONS
            end
          elsif @assignments_to_show&.one?
            SMALL_ITEM_LOCATIONS
          else
            WIDE_ITEM_LOCATIONS
          end
        end

        def load_from_tile
          @assignments = @tile.hex&.assignments || {}
          @assignments_to_show = []
          stack_group_count = Hash.new(0)
          stack_group_img = {}
          @assignments.each_key do |assignment|
            stack_group = @game.assignment_stack_group(assignment)
            img = @game.assignment_tokens(assignment, setting_for(:simple_logos, @game))

            if stack_group
              stack_group_count[stack_group] += 1
              stack_group_img[stack_group] = img
            else
              @assignments_to_show.append({ 'img' => img, 'count' => 1 })
            end
          end

          stack_group_count.each do |group, count|
            @assignments_to_show.append({ 'img' => stack_group_img[group], 'count' => count })
          end
        end

        def stack_count_background_props(axis, axis_value)
          props = {
            attrs: {
              href: '/icons/stack_background.svg',
              width: "#{ICON_RADIUS * 2}px",
              height: "#{ICON_RADIUS * 2}px",
            },
          }

          props[:attrs][axis] = axis_value + 10
          axis2 = (POINTY_TALL_ITEM_LOCATIONS.any?(render_location) ? :x : :y)
          props[:attrs][axis2] = -5
          props
        end

        def stack_count_props(axis, axis_value)
          props = {
            attrs: {
              'dominant-baseline': 'central',
              fill: 'black',
            },
            style: {
              fontSize: '20px',
            },
          }
          props[:attrs][axis] = axis_value + 35
          axis2 = (POINTY_TALL_ITEM_LOCATIONS.any?(render_location) ? :x : :y)
          props[:attrs][axis2] = 8
          props
        end

        def render_part
          axis = (POINTY_TALL_ITEM_LOCATIONS.any?(render_location) ? :y : :x)
          multiplyer = (POINTY_WIDER_ITEM_LOCATIONS.any?(render_location) ? 3 : 1)

          if @game
            children = []
            @assignments_to_show.each.with_index do |assignment, index|
              count = assignment[:count]

              props = {
                attrs: {
                  href: assignment[:img],
                  width: "#{ICON_RADIUS * 2}px",
                  height: "#{ICON_RADIUS * 2}px",
                },
              }

              axis_value = ((index - ((@assignments_to_show.size - 1) / 2)) * multiplyer * DELTA).round(2)
              props[:attrs][axis] = axis_value

              children.append(h(:image, props))
              if count > 1
                props = stack_count_background_props(axis, axis_value)
                children.append(h(:image, props))

                props = stack_count_props(axis, axis_value)
                children.append(h(:text, props, count))
              end
            end
          end
          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-ICON_RADIUS} #{-ICON_RADIUS})" } },
            [h(:g, { attrs: { transform: translate } }, children)])
        end
      end
    end
  end
end
