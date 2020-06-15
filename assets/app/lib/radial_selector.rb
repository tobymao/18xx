# frozen_string_literal: true

module Lib
  module RadialSelector
    # item -> [x,y,item]
    def list_coordinates(list, distance, offset)
      theta = 360.0 / list.size * Math::PI / 180
      list.map.with_index do |x, index|
        [
          x,
          distance * Math.cos(index * theta) - offset,
          distance * Math.sin(index * theta) - offset,
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
        filter: 'drop-shadow(5px 5px 2px #888)',
        'pointer-events' => 'auto',
      }
    end
  end
end
