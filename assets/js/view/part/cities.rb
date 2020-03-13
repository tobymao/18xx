# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/city'

module View
  module Part
    class Cities < Snabberb::Component
      needs :tile
      needs :region_use

      def render
        h(Part::City, region_use: @region_use, city: @tile.cities.first) if @tile.cities.count == 1
      end
    end
  end
end
