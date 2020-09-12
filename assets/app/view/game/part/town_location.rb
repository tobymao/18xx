# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      module TownLocation
        SINGLE_STOP_TWO_EXIT_REGIONS = {
          straight: [Base::CENTER] * 6,
          sharp: [
            [14, 15, 19, 20],
            [5, 7, 12, 14],
            [0, 1, 7, 8],
            [3, 4, 8, 9],
            [9, 11, 16, 18],
            [15, 16, 22, 23],
          ],
          gentle: [
            [14],
            [7],
            [8],
            [9],
            [16],
            [15],
          ],
        }.freeze

        MULTIPLE_STOP_TWO_EXIT_REGIONS = {
          straight: [
            [15],
            [14],
            [7],
            [8],
            [9],
            [16],
          ],
          sharp: [
            [15, 20, 21],
            [12, 13, 14],
            [0, 6, 7],
            [2, 3, 8],
            [9, 10, 11],
            [16, 17, 23],
          ],
          gentle: [
            [15, 12],
            [13, 14],
            [6, 7],
            [2, 8],
            [9, 10],
            [16, 17],
          ],
        }.freeze

        EDGE_TOWN_REGIONS = {
          0 => [21],
          0.5 => [13, 21],
          1 => [13],
          1.5 => [6, 13],
          2 => [6],
          2.5 => [2, 6],
          3 => [2],
          3.5 => [2, 10],
          4 => [10],
          4.5 => [10, 17],
          5 => [17],
          5.5 => [17, 21],
        }.freeze

        # absolute value of angle (in degrees) to tilt the town rectangle relative
        # to a straight line from edge_a to the opposite edge
        RECTANGLE_TILT = {
          sharp: 40,
          gentle: 15,
        }.freeze

        # from center of the hex, how many degrees of offset to apply to
        # positioning the town rectangle; this value will be added/subtracted to
        # (edge_a * 60)
        POSITIONAL_ANGLE = {
          sharp: 12.12,
          gentle: 6.11,
        }.freeze

        # Returns the two edges plus min edge so that a is the edge to render close to, and
        # (a - b).abs is 1, 2 or 3.
        def normalized_edges(edge_a, exits)
          @@normalized_edges ||= {}
          @@normalized_edges[[edge_a, exits]] ||= if edge_a && exits.size == 2
                                                    edge_b = exits.find { |e| e != edge_a }
                                                    edges = [edge_a, edge_b]
                                                    edges[edges.index(edges.min)] += 6 if (edge_a - edge_b).abs > 3
                                                    edges
                                                  else
                                                    [edge_a, nil]
                                                  end
        end

        def min_edge(edges)
          @@min_edge ||= {}
          @@min_edge[edges] ||= edges.min
        end

        # Returns a symbol of :straight, :gentle or :sharp based on the absolute
        # difference of the normalized edges
        def town_track_type(edges)
          @@town_track_type ||= {}
          @@town_track_type[edges] ||=
            begin
              edge_a, edge_b = edges
              [nil, :sharp, :gentle, :straight][(edge_a - edge_b).abs]
            end
        end

        # Returns a symbol of :left, :right, or :straight based on the direction
        # the track curves starting from edge_a
        def town_track_direction(edges)
          @@town_track_direction ||= {}
          @@town_track_direction[edges] ||=
            begin
              edge_a, edge_b = edges

              if (edge_a - edge_b).abs == 3
                :straight
              elsif edge_a > edge_b
                :right
              elsif edge_a < edge_b
                :left
              end
            end
        end

        # Returns an array of options for track positions
        def town_track_location(tile, town, edges)
          edge_a, = edges

          loc = if town.exits.size == 2 && tile.stops.one?
                  SINGLE_STOP_TWO_EXIT_REGIONS[town_track_type(edges)][min_edge(edges)]
                elsif town.exits.size == 2
                  MULTIPLE_STOP_TWO_EXIT_REGIONS[town_track_type(edges)][edge_a % 6]
                elsif edge_a
                  EDGE_TOWN_REGIONS[edge_a]
                else
                  Base::CENTER
                end
          [loc]
        end

        # Returns an array of rotation options for the town rectangle that
        # corresponds to the positions given from track_location
        def town_rotation_angles(tile, town, edges)
          edge_a, = edges

          if town.exits.size == 2 && tile.stops.one?
            case town_track_type(edges)
            when :straight
              [min_edge(edges) * 60]
            when :sharp
              [(min_edge(edges) + 2) * 60]
            when :gentle
              [(min_edge(edges) * 60) - 30]
            end
          elsif town.exits.size == 2
            tilt = RECTANGLE_TILT[town_track_type(edges)] || 0

            delta = case town_track_direction(edges)
                    when :straight
                      0
                    when :left
                      -tilt
                    when :right
                      tilt
                    end

            [(edge_a * 60) + delta]
          elsif edge_a
            [edge_a * 60]
          else
            # This town is in the center. Find the orientation of the town
            # by looking at the first path connected to it
            path = town.paths.first
            if (edge = path.exits&.first)
              [edge * 60]
            else
              other_stop = (path.stops - [town]).first
              other_edge = tile.preferred_city_town_edges[other_stop] if other_stop
              if other_edge
                [other_edge * 60]
              else
                [0]
              end
            end
          end
        end

        # Returns an array of weights, location and rotations
        def town_position(tile, town, edges)
          edge_a, = edges

          if town.exits.size == 2 && tile.stops.one?
            angles, positions = case town_track_type(edges)
                                when :straight
                                  [[edge_a * 60], [0]]
                                when :sharp
                                  [[(min_edge(edges) + 0.5) * 60], [50]]
                                when :gentle
                                  [[(min_edge(edges) + 1) * 60], [23.2]]
                                end
          elsif town.exits.size == 2
            positional_angle = POSITIONAL_ANGLE[town_track_type(edges)] || 0

            delta = case town_track_direction(edges)
                    when :straight
                      0
                    when :left
                      positional_angle
                    when :right
                      -positional_angle
                    end

            angles = [(edge_a * 60) + delta]

            positions = case town_track_type(edges)
                        when :straight
                          [40]
                        when :sharp
                          [55.70]
                        when :gentle
                          [48.05]
                        end
          elsif edge_a
            angles = [edge_a * 60]
            # need to push town close to edge if 3 or 4 slot city on same tile
            positions = if tile.cities.one? && tile.cities[0].slots == 3
                          [65]
                        elsif tile.cities.one? && tile.cities[0].slots == 4
                          [70]
                        else
                          [50]
                        end
          else
            angles = [0]
            positions = [0]
          end

          radians = angles.map { |a| a / 180 * Math::PI }

          xs = positions.zip(radians).map { |p, r| -Math.sin(r) * p }
          ys = positions.zip(radians).map { |p, r| Math.cos(r) * p }

          town_track_location(tile, town, edges).zip(xs, ys, town_rotation_angles(tile, town, edges))
        end
      end
    end
  end
end
