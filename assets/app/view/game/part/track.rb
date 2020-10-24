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

          paths_and_stubs = @tile.paths + @tile.stubs
          path_indexes = paths_and_stubs.map { |p| [p, indexes_for(p)] }.to_h

          sorted = paths_and_stubs
            .map { |path| path_indexes[path].map { |i| [path, i] } }.flatten(1)
            .sort_by { |_, index| index || -1 }

          sorted.map do |path, index|
            props = {
              color: value_for_index(index, :color),
              width: width_for_index(path, index, path_indexes),
              dash: value_for_index(index, :dash),
            }

            if path.stub?
              h(TrackStub, stub: path, region_use: @region_use, **props)
            elsif path.offboard
              h(TrackOffboard, offboard: path.offboard, path: path, region_use: @region_use, **props)
            else
              h(TrackNodePath, tile: @tile, path: path, region_use: @region_use, **props)
            end
          end
        end

        private

        def indexes_for(path)
          indexes = @routes_paths
            .map.with_index
            .select { |route_paths, _index| route_paths.any? { |p| path == p } }
            .flat_map { |_, index| index }

          indexes.empty? ? [nil] : indexes
        end

        def value_for_index(index, prop)
          index ? route_prop(index, prop) : TRACK[prop]
        end

        def width_for_index(path, index, path_indexes)
          multiplier =
            if !index || path_indexes[path].one?
              1
            else
              [1, 3 * path_indexes[path].reverse.index(index)].max
            end

          value_for_index(index, :width) * multiplier
        end
      end
    end
  end
end
