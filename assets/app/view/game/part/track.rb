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
          width: 9,
          dash: '0',
          broad: {
            color: '#000000',
            width: 9,
            dash: '0',
          },
          narrow: {
            color: '#000000',
            width: 12,
            dash: '0',
          },
          dual: {
            color: '#FFFFFF',
            width: 10,
            dash: '0',
          },
          thin: {
            color: '#000000',
            width: 2,
            dash: '12',
          },
          future: {
            color: '#888888',
            width: 6,
            dash: '9 3',
          },
        }.freeze

        # width here is added to track width
        BORDER_PROPS = {
          broad: {
            color: '#FFFFFF',
            width: 3,
          },
          narrow: {
            color: '#FFFFFF',
            width: 2,
          },
          dual: {
            color: '#000000',
            width: 3,
          },
          thin: {
            color: '#FFFFFF',
            width: 0,
            dash: '12',
          },
          future: {
            color: '#00000000',
            width: 0,
            dash: '9 3',
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

          paths_and_stubs = @tile.paths + @tile.stubs + @tile.future_paths
          path_indexes = paths_and_stubs.to_h { |p| [p, indexes_for(p)] }

          sorted = paths_and_stubs
            .flat_map { |path| path_indexes[path].map { |i| [path, i] } }
            .sort_by { |_, index| index || -1 }

          # Main track
          #
          # Non-stub/offboard track requires up to three passes:
          # - Draw borders
          # - Draw the actual track
          # - Draw the stripped inner bits (narrow gauge only)
          #
          # Each pass has to be grouped together so that track "switches" are rendered correctly
          #
          # Stubs and offboards can be done in a single pass because they don't have switches
          #
          pass0 = []
          pass1 = []
          pass2 = []
          sorted.each do |path, index|
            props = {
              color: value_for_index(index, :color, path.track),
              width: width_for_index(path, index, path_indexes),
              dash: value_for_index(index, :dash, path.track),
            }

            border_props = BORDER_PROPS[path.track]
            inner_props = INNER_PROPS[path.track]

            if path.stub?
              pass1 << h(TrackStub, stub: path, region_use: @region_use, border_props: border_props, **props)
            elsif path.offboard
              pass1 << h(TrackOffboard, offboard: path.offboard, path: path, region_use: @region_use,
                                        border_props: border_props, **props)
            elsif path.track == :thin || path.track == :future
              pass1 << h(TrackNodePath, tile: @tile, path: path, region_use: @region_use,
                                        pass: 1, border_props: border_props, inner_props: inner_props, **props)

            else
              pass0 << h(TrackNodePath, tile: @tile, path: path, region_use: @region_use,
                                        pass: 0, border_props: border_props, inner_props: inner_props, **props)
              pass1 << h(TrackNodePath, tile: @tile, path: path, region_use: @region_use,
                                        pass: 1, border_props: border_props, inner_props: inner_props, **props)
              if inner_props
                pass2 << h(TrackNodePath, tile: @tile, path: path, region_use: @region_use,
                                          pass: 2, border_props: border_props, inner_props: inner_props, **props)
              end
            end
          end
          pass0.concat(pass1).concat(pass2)
        end

        private

        def indexes_for(path)
          indexes = @routes_paths
            .map.with_index
            .select { |route_paths, _index| route_paths.any? { |p| path == p } }
            .flat_map { |_, index| index }

          indexes.empty? ? [nil] : indexes
        end

        def value_for_index(index, prop, track)
          return TRACK[track][prop] if index && track == :narrow && prop == :dash
          return TRACK[track][prop] if track == :thin && prop == :dash

          index ? route_prop(index, prop) : TRACK[track][prop]
        end

        def width_for_index(path, index, path_indexes)
          width = value_for_index(index, :width, path.track).to_f

          width =
            if index && path_indexes[path].size > 1
              [width, MULTI_PATH[path.track][:width]].min
            else
              [width, TRACK[path.track][:width]].max
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
