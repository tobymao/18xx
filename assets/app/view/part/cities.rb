# frozen_string_literal: true

require 'view/part/city'

module View
  module Part
    class Cities < Base
      def render
        @tile.cities.map do |city|
          h(Part::City, region_use: @region_use, tile: @tile, city: city)
        end
      end
    end
  end
end
