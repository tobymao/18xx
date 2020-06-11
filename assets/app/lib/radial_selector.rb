# frozen_string_literal: true

require 'view/game/hex'

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
  end
end
