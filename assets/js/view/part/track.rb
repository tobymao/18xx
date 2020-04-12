# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/track_curvilinear_path'
require 'view/part/track_curvilinear_half_path'
require 'view/part/track_lawson_path'
require 'view/part/track_offboard'

module View
  module Part
    class Track < Snabberb::Component
      ROUTE_COLORS = %i[red blue green purple].freeze

      needs :tile
      needs :region_use
      needs :routes

      def render
        # each route has an "entry" in this array; each "entry" is an array of
        # the paths on that route that are also on this tile
        #
        # Array<Array<Path>>
        @routes_paths = @routes.map { |route| route.paths_for(@tile.paths) }

        if !@tile.offboards.empty?
          track_class = Part::TrackOffboard
          paths = @tile.paths.select(&:offboard)
        elsif @tile.lawson?
          track_class = Part::TrackLawsonPath
          paths = @tile.paths.select { |path| path.edges.size == 1 }
        elsif @tile.towns.any?
          return render_track_for_curvilinear_town
        else
          track_class = Part::TrackCurvilinearPath
          paths = @tile.paths.select { |path| path.edges.size == 2 }
        end

        paths.map do |path|
          h(track_class, region_use: @region_use, path: path, color: color_for(path))
        end
      end

      private

      def render_track_for_curvilinear_town
        @tile.paths.select(&:town).group_by(&:town).flat_map do |_, paths|
          exits = paths.flat_map(&:exits)

          paths.map do |path|
            h(
              Part::TrackCurvilinearHalfPath,
              region_use: @region_use,
              exits: exits,
              path: path,
              color: color_for(path),
            )
          end
        end
      end

      def color_for(path)
        index = @routes_paths.find_index do |route_paths|
          route_paths.any? do |p|
            path == p
          end
        end
        index ? self.class::ROUTE_COLORS[index] : 'black'
      end
    end
  end
end
