# frozen_string_literal: true

require 'view/game/part/town_dot'
require 'view/game/part/town_rect'

module View
  module Game
    module Part
      class Towns < Snabberb::Component
        needs :tile
        needs :region_use
        needs :routes

        def render
          @tile.towns.map do |town|
            if @tile.lawson? || @tile.paths.empty?
              h(TownDot, town: town, tile: @tile, region_use: @region_use, color: color_for(town))
            else
              h(TownRect, town: town, region_use: @region_use, color: color_for(town))
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
          index ? Part::Track::ROUTE_COLORS[index] : 'black'
        end
      end
    end
  end
end
