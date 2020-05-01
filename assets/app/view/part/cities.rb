# frozen_string_literal: true

require 'view/part/city'

module View
  module Part
    class Cities < Base
      def render
        @tile.cities.map do |city|
          edges = @tile.paths.select { |path| path.city.equal?(city) }.flat_map(&:exits)
          h(Part::City, region_use: @region_use, tile: @tile, city: city, edges: edges)
        end
      end
    end
  end
end
