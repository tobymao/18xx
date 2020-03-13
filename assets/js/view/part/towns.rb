# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/town_dot'

module View
  module Part
    class Towns < Snabberb::Component
      needs :tile
      needs :region_use

      def render
        @tile.towns.map do |_town|
          h(Part::TownDot, region_use: @region_use) if @tile.lawson?
        end.compact
      end
    end
  end
end
