# frozen_string_literal: true

require 'view/game/part/base'
require 'view/game/part/small_item'

module View
  module Game
    module Part
      class Assignments < Base
        include SmallItem
        needs :game, store: true
        ICON_RADIUS = 20
        DELTA_X = (ICON_RADIUS * 2) + 2

        def preferred_render_locations
          if layout == :pointy && @assignments.one?
            POINTY_SMALL_ITEM_LOCATIONS
          elsif layout == :pointy
            POINTY_WIDE_ITEM_LOCATIONS
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
          children = @assignments.keys.map.with_index do |assignment, index|
            img = @game.class::ASSIGNMENT_TOKENS[assignment]
            h(:image,
              attrs: {
                href: img,
                x: index * -DELTA_X,
                width: "#{ICON_RADIUS * 2}px",
                height: "#{ICON_RADIUS * 2}px",
              })
          end

          h(:g, { attrs: { transform: "#{rotation_for_layout} translate(#{-ICON_RADIUS} #{-ICON_RADIUS})" } }, [
              h(:g, { attrs: { transform: translate } }, children),
            ])
        end
      end
    end
  end
end
