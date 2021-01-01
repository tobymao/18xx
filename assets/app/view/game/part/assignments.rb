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
          if layout == :pointy && @assignments.one?
            POINTY_SMALL_ITEM_LOCATIONS
          elsif layout == :pointy && @assignments&.size == 2
            POINTY_WIDE_ITEM_LOCATIONS + POINTY_TALL_ITEM_LOCATIONS + POINTY_WIDER_ITEM_LOCATIONS
          elsif layout == :flat && @assignments.one?
            POINTY_WIDE_ITEM_LOCATIONS + POINTY_TALL_ITEM_LOCATIONS
          elsif layout == :flat && @assignments.one?
            SMALL_ITEM_LOCATIONS
          else
            WIDE_ITEM_LOCATIONS
          end
        end

        def load_from_tile
          @assignments = @tile.hex.assignments
        end

        def render_part
          axis = (POINTY_TALL_ITEM_LOCATIONS.any?(render_location) ? :y : :x)
          multiplyer = (POINTY_WIDER_ITEM_LOCATIONS.any?(render_location) ? 3 : 1)

          children = @assignments.keys.map.with_index do |assignment, index|
            img = @game.assignment_tokens(assignment)

            props = { attrs: {
              href: img,
              width: "#{ICON_RADIUS * 2}px",
              height: "#{ICON_RADIUS * 2}px",
            } }
            props[:attrs][axis] = ((index - (@assignments.size - 1) / 2) * multiplyer * DELTA).round(2)

            h(:image, props)
          end if @game

          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-ICON_RADIUS} #{-ICON_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
        end
      end
    end
  end
end
