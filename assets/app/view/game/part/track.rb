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
          width: 12,
          dash: '0',
          broad: {
            color: '#000000',
            width: 12,
            dash: '0',
          },
          narrow: {
            color: '#000000',
            width: 12,
            dash: '0',
          },
          dual: {
            color: '#FFFFFF',
            width: 12,
            dash: '0',
          },
        }.freeze

        # width here is added to track width
        BORDER_PROPS = {
          broad: {
            color: '#FFFFFF',
            width: 4,
          },
          narrow: {
            color: '#FFFFFF',
            width: 4,
          },
          dual: {
            color: '#000000',
            width: 4,
          },
        }.freeze

        # width here is subtracted from track width
        INNER_PROPS = {
          narrow: {
            color: '#FFFFFF',
            width: 4,
            dash: '12',
          },
        }.freeze

        # use narrower track when showing more than one route on a path
        MULTI_PATH = {
          broad: {
            width: 8,
          },
          narrow: {
            width: 8,
          },
          dual: {
            width: 8,
          },
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
            .flat_map { |path| path_indexes[path].map { |i| [path, i] } }
            .sort_by { |_, index| index || -1 }

          # track outline
          # this has to be done in a separate pass to render connections ("switches")
          # between tracks correctly
          passes = sorted.map do |path, index|
            props = {
              color: value_for_index(index, :color, path.gauge),
              width: width_for_index(path, index, path_indexes),
              dash: value_for_index(index, :dash, path.gauge),
            }

            border_props = BORDER_PROPS[path.gauge]
            inner_props = INNER_PROPS[path.gauge]

            if !path.stub? && !path.offboard
              h(TrackNodePath, tile: @tile, path: path, region_use: @region_use,
                               pass: 0, border_props: border_props, inner_props: inner_props, **props)
            end
          end

          # Main track
          pass1 = sorted.map do |path, index|
            props = {
              color: value_for_index(index, :color, path.gauge),
              width: width_for_index(path, index, path_indexes),
              dash: value_for_index(index, :dash, path.gauge),
            }

            border_props = BORDER_PROPS[path.gauge]
            inner_props = INNER_PROPS[path.gauge]

            if path.stub?
              h(TrackStub, stub: path, region_use: @region_use, border_props: border_props, **props)
            elsif path.offboard
              h(TrackOffboard, offboard: path.offboard, path: path, region_use: @region_use,
                               border_props: border_props, **props)
            else
              h(TrackNodePath, tile: @tile, path: path, region_use: @region_use,
                               pass: 1, border_props: border_props, inner_props: inner_props, **props)
            end
          end

          # inner portion of track (narrow gauge)
          # this has to be done in a separate pass for the same reason as the outline
          pass2 = sorted.map do |path, index|
            props = {
              color: value_for_index(index, :color, path.gauge),
              width: width_for_index(path, index, path_indexes),
              dash: value_for_index(index, :dash, path.gauge),
            }

            border_props = BORDER_PROPS[path.gauge]
            inner_props = INNER_PROPS[path.gauge]

            if !path.stub? && !path.offboard && inner_props
              h(TrackNodePath, tile: @tile, path: path, region_use: @region_use,
                               pass: 2, border_props: border_props, inner_props: inner_props, **props)
            end
          end.compact
          passes.concat(pass1)
          passes.concat(pass2) unless pass2.empty?
          passes
        end

        private

        def indexes_for(path)
          indexes = @routes_paths
            .map.with_index
            .select { |route_paths, _index| route_paths.any? { |p| path == p } }
            .flat_map { |_, index| index }

          indexes.empty? ? [nil] : indexes
        end

        def value_for_index(index, prop, gauge)
          return TRACK[gauge][prop] if index && gauge == :narrow && prop == :dash

          index ? route_prop(index, prop) : TRACK[gauge][prop]
        end

        def width_for_index(path, index, path_indexes)
          width = [value_for_index(index, :width, path.gauge), TRACK[path.gauge][:width]].max
          if index && path_indexes[path].size > 1
            width = [value_for_index(index, :width, path.gauge), MULTI_PATH[path.gauge][:width]].min
          end
          multiplier =
            if !index || path_indexes[path].one?
              1
            else
              [1, 3 * path_indexes[path].reverse.index(index)].max
            end

          width.to_f * multiplier.to_i
        end
      end
    end
  end
end
