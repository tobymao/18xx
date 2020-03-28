# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/town_dot'

module View
  module Part
    class Towns < Snabberb::Component
      needs :tile
      needs :region_use

      def render
        @tile.towns.map do |_|
          h(Part::TownDot, region_use: @region_use) if @tile.lawson?
        end
      end
    end
  end
end
