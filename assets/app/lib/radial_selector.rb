# frozen_string_literal: true

module Lib
  module RadialSelector
    DROP_SHADOW_SIZE = 5

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
      }
    end
  end
end
