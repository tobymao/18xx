# frozen_string_literal: true

require 'lib/settings'
require 'view/game/part/double_town_dot'
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
          rendered = @tile.towns.each_with_object([]) do |town, parts|
            next if town.hidden?

            parts <<
              if town.rect?
                h(TownRect, town: town, region_use: @region_use, show_revenue: @show_revenue,
                            color: value_for(town, :color), width: value_for(town, :width))
              else
                h(TownDot, town: town, tile: @tile, region_use: @region_use, show_revenue: @show_revenue,
                           color: value_for(town, :color), width: value_for(town, :width))
              end
          end

          @tile.double_towns.each do |double_town|
            rendered << h(DoubleTownDot, double_town: double_town, tile: @tile, region_use: @region_use,
                                         show_revenue: @show_revenue,
                                         color: value_for(double_town.towns, :color),
                                         width: value_for(double_town.towns, :width))
          end

          rendered
        end

        def value_for(towns, prop)
          towns = [towns].flatten
          @routes_paths = @routes.map { |route| route.paths_for(@tile.paths) }

          index = @routes_paths.find_index do |route_paths|
            route_paths.any? do |p|
              towns.include?(p.town)
            end
          end
          index ? route_prop(index, prop) : Track::TRACK[prop]
        end
      end
    end
  end
end
