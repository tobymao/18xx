# frozen_string_literal: true

require 'lib/settings'
require 'view/game/part/track_curvilinear_path'
require 'view/game/part/track_curvilinear_half_path'
require 'view/game/part/track_lawson_path'
require 'view/game/part/track_offboard'

module View
  module Game
    module Part
      class Track < Snabberb::Component
        include Lib::Settings

        TRACK = {
          color: '#000000',
          width: 8,
          dash: '0',
        }.freeze

        needs :tile
        needs :region_use
        needs :routes

        def render
          # each route has an "entry" in this array; each "entry" is an array of
          # the paths on that route that are also on this tile
          #
          # Array<Array<Path>>
          @routes_paths = @routes.map { |route| route.paths_for(@tile.paths) }

          if @tile.offboards.any?
            @tile.paths.select(&:offboard).map do |path|
              h(TrackOffboard, offboard: path.offboard, path: path, region_use: @region_use,
                               color: prop_for(path, :color), width: prop_for(path, :width),
                               dash: prop_for(path, :dash),)
            end
          elsif @tile.lawson?
            @tile.paths.select { |path| path.edges.one? }.map do |path|
              h(TrackLawsonPath, path: path, region_use: @region_use,
                                 color: prop_for(path, :color), width: prop_for(path, :width),
                                 dash: prop_for(path, :dash),)
            end
          elsif @tile.towns.any?
            render_track_for_curvilinear_town
          elsif @tile.cities.any?
            render_track_for_curvilinear_city
          else
            @tile.paths.select { |path| path.edges.size == 2 }
            .map { |path| [path, index_for(path)] }
            .sort_by { |_, index| index || -1 }
            .map do |path, index|
              h(TrackCurvilinearPath, region_use: @region_use, path: path, color: prop_for_index(index, :color),
                                      width: prop_for(path, :width), dash: prop_for(path, :dash),)
            end
          end
        end

        private

        def render_track_for_curvilinear_city
          @tile.cities.flat_map do |city|
            exits = city.exits

            city.paths.map do |path|
              h(TrackCurvilinearHalfPath, exits: exits, path: path, region_use: @region_use,
                                          color: prop_for(path, :color), width: prop_for(path, :width),
                                          dash: prop_for(path, :dash),)
            end
          end
        end

        def render_track_for_curvilinear_town
          @tile.towns.flat_map do |town|
            exits = town.exits

            town.paths.map do |path|
              h(TrackCurvilinearHalfPath, exits: exits, path: path, region_use: @region_use,
                                          color: prop_for(path, :color), width: prop_for(path, :width),
                                          dash: prop_for(path, :dash),)
            end
          end
        end

        def index_for(path)
          @routes_paths.find_index do |route_paths|
            route_paths.any? { |p| path == p }
          end
        end

        def prop_for_index(index, prop)
          index ? setting_for("r#{index}_#{prop}") : TRACK[prop]
        end

        def prop_for(path, prop)
          prop_for_index(index_for(path), prop)
        end
      end
    end
  end
end
