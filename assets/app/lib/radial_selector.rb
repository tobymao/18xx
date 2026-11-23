# frozen_string_literal: true

module Lib
  module RadialSelector
    DROP_SHADOW_SIZE = 5
    FULL_CIRCLE = 360

    # Opens a fan away from whichever map edge(s) are too close for it to
    # render at full size -- a full circle when none are, a half circle
    # when near one edge, a quarter circle in a corner -- then rotates
    # that fan to point back toward the center of the viewport.
    def calc_angle_rotation(left, right, top, bottom)
      angle = case [left, right, top, bottom].count(true)
              when 0 # center
                rotation = 0
                FULL_CIRCLE
              when 1 # side
                180
              else # corner
                90
              end
      rotation ||= if left && !bottom
                     -90
                   elsif !left && top
                     -180
                   elsif right && !top
                     -270
                   else
                     0
                   end
      [angle, rotation]
    end

    # item -> [item,x,y]
    # angle = opening angle for tile fan
    # rotate counterclockwise by rotation degrees
    def list_coordinates(list, distance, offset, angle = 360, rotation = 0)
      angle = angle * list.size / (list.size - 1) if angle < 360 && list.size > 1
      theta = angle / list.size * Math::PI / 180
      list.map.with_index do |item, index|
        [
          item,
          (distance * Math.cos((index * theta) + (rotation / 180 * Math::PI))) - offset,
          (distance * Math.sin((index * theta) + (rotation / 180 * Math::PI))) - offset,
        ]
      end
    end

    def style(left, bottom, size)
      {
        position: 'absolute',
        left: "#{left}px",
        bottom: "#{bottom}px",
        width: "#{size}px",
        height: "#{size}px",
        filter: "drop-shadow(#{DROP_SHADOW_SIZE}px #{DROP_SHADOW_SIZE}px 2px #555)",
        pointerEvents: 'auto',
        # set z-index to ensure that these tiles appear at the topmost level.
        'z-index': '1',
      }
    end
  end
end
