# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/town_dot'
require 'view/part/town_rect'

module View
  module Part
    class Towns < Snabberb::Component
      ROUTE_COLORS = %i[red blue green purple].freeze

      needs :tile
      needs :region_use
      needs :routes

      def render
        @tile.towns.map do |town|
          if @tile.lawson?
            h(Part::TownDot, region_use: @region_use, color: color_for(town))
          else
            paths = @tile.paths_with(%w[town], town)
            edges = paths.flat_map(&:exits)
            h(Part::TownRect, region_use: @region_use, color: color_for(town), edges: edges)
          end
        end
      end

      def color_for(town)
        @routes_paths = @routes.map { |route| route.paths_for(@tile.paths) }

        index = @routes_paths.find_index do |route_paths|
          route_paths.any? do |p|
            p.town == town
          end
        end
        index ? self.class::ROUTE_COLORS[index] : 'black'
      end
    end
  end
end
