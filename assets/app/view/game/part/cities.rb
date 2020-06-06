# frozen_string_literal: true

require 'view/game/part/city'

module View
  module Game
    module Part
      class Cities < Base
        def render
          @tile.cities.map do |city|
            h(City, region_use: @region_use, tile: @tile, city: city)
          end
        end
      end
    end
  end
end
