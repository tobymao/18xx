# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Assignments < Base
        include SmallItem
        needs :game, default: nil, store: true
        ICON_RADIUS = 20
        DELTA = (ICON_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :pointy
            case @assignments&.size
            when 1
              POINTY_SMALL_ITEM_LOCATIONS
            when 2
              POINTY_WIDE_ITEM_LOCATIONS + POINTY_TALL_ITEM_LOCATIONS + POINTY_WIDER_ITEM_LOCATIONS
            else
              POINTY_WIDE_ITEM_LOCATIONS
            end
          elsif @assignments.one?
            SMALL_ITEM_LOCATIONS
          else
            WIDE_ITEM_LOCATIONS
          end
        end

        def load_from_tile
          @assignments = @tile.hex&.assignments || {}
        end

        def render_part
          axis = (POINTY_TALL_ITEM_LOCATIONS.any?(render_location) ? :y : :x)
          multiplyer = (POINTY_WIDER_ITEM_LOCATIONS.any?(render_location) ? 3 : 1)

          if @game
            children = @assignments.keys.map.with_index do |assignment, index|
              img = @game.assignment_tokens(assignment)

              props = {
                attrs: {
                  href: img,
                  width: "#{ICON_RADIUS * 2}px",
                  height: "#{ICON_RADIUS * 2}px",
                },
              }
              props[:attrs][axis] = ((index - ((@assignments.size - 1) / 2)) * multiplyer * DELTA).round(2)

              h(:image, props)
            end
          end

          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-ICON_RADIUS} #{-ICON_RADIUS})" } },
            [h(:g, { attrs: { transform: translate } }, children)])
        end
      end
    end
  end
end
