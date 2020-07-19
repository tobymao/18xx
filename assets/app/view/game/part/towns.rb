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

        def render
          @tile.towns.map do |town|
            if @tile.lawson? || @tile.paths.empty?
              h(TownDot, town: town, tile: @tile, region_use: @region_use,
                         color: prop_for(town, :color), width: prop_for(town, :width))
            else
              h(TownRect, town: town, region_use: @region_use,
                          color: prop_for(town, :color), width: prop_for(town, :width))
            end
          end
        end

        def prop_for(town, prop)
          @routes_paths = @routes.map { |route| route.paths_for(@tile.paths) }

          index = @routes_paths.find_index do |route_paths|
            route_paths.any? do |p|
              p.town == town
            end
          end
          index ? setting_for("r#{index}_#{prop}") : Track::TRACK[prop]
        end
      end
    end
  end
end
