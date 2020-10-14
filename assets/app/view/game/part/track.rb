# frozen_string_literal: true

require 'lib/settings'
require 'view/game/part/track_node_path'
require 'view/game/part/track_offboard'
require 'view/game/part/track_stub'

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

          sorted = (@tile.paths + @tile.path_stubs)
            .map { |path| [path, index_for(path)] }
            .sort_by { |_, index| index || -1 }

          sorted.map do |path, index|
            props = {
              color: value_for_index(index, :color),
              width: value_for_index(index, :width),
              dash: value_for_index(index, :dash),
            }

            if path.path_stub?
              h(TrackStub, path_stub: path, region_use: @region_use, **props)
            elsif path.offboard
              h(TrackOffboard, offboard: path.offboard, path: path, region_use: @region_use, **props)
            else
              h(TrackNodePath, tile: @tile, path: path, region_use: @region_use, **props)
            end
          end
        end

        private

        def index_for(path)
          @routes_paths.index do |route_paths|
            route_paths.any? { |p| path == p }
          end
        end

        def value_for_index(index, prop)
          index ? route_prop(index, prop) : TRACK[prop]
        end
      end
    end
  end
end
