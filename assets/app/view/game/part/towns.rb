# frozen_string_literal: true

require 'lib/settings'
require 'view/game/part/town_dot'
require 'view/game/part/town_rect'

module View
  module Game
    module Part
      class Towns < Snabberb::Component
        include Lib::Settings

        needs :tile
        needs :region_use
        needs :routes
        needs :show_revenue

        def render
          @tile.towns.each_with_object([]) do |town, rendered|
            next if town.hidden?

            rendered <<
              if town.rect?
                h(TownRect, town: town, region_use: @region_use, show_revenue: @show_revenue,
                            color: value_for(town, :color), width: value_for(town, :width))
              else
                h(TownDot, town: town, tile: @tile, region_use: @region_use, show_revenue: @show_revenue,
                           color: value_for(town, :color), width: value_for(town, :width))
              end
          end
        end

        def value_for(town, prop)
          @routes_paths = @routes.map { |route| route.paths_for(@tile.paths) }

          index = @routes_paths.find_index do |route_paths|
            route_paths.any? do |p|
              p.town == town
            end
          end
          index ? route_prop(index, prop) : Track::TRACK[prop]
        end
      end
    end
  end
end
