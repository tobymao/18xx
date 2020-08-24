# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class TrackNodePath < Base
        needs :tile
        needs :path
        needs :color, default: 'black'
        needs :width, default: 8
        needs :dash, default: '0'

        EDGE_PERP_ANGLES = [90, 30, -30, -90, -150, 150].freeze

        EDGE_REGIONS = {
          0 => TRACK_TO_EDGE_0,
          0.5 => [14, 15],
          1 => TRACK_TO_EDGE_1,
          1.5 => [7, 14],
          2 => TRACK_TO_EDGE_2,
          2.5 => [7, 8],
          3 => TRACK_TO_EDGE_3,
          3.5 => [8, 9],
          4 => TRACK_TO_EDGE_4,
          4.5 => [9, 16],
          5 => TRACK_TO_EDGE_5,
          5.5 => [15, 16],
        }.freeze

        EXIT0_TO_EDGE_BEZIER_REGIONS = {
          0 => [21],
          0.5 => [21],
          1 => [13, 14, 15, 21],
          1.5 => [14, 15, 21],
          2 => [6, 7, 14, 15, 21],
          2.5 => [7, 14, 15, 21],
          3 => [2, 8, 15, 21],
          3.5 => [9, 15, 16, 21],
          4 => [9, 10, 15, 16, 21],
          4.5 => [15, 16, 21],
          5 => [15, 16, 17, 21],
          5.5 => [21],
        }.freeze

        EXIT0_TO_EDGE_LINE_REGIONS = {
          0 => [21],
          0.5 => [20, 21],
          1 => [13, 19, 20],
          1.5 => [13, 14, 15, 21],
          2 => [6, 7, 14, 15, 21],
          2.5 => [7, 14, 15, 21],
          3 => [2, 8, 15, 21],
          3.5 => [9, 15, 16, 21],
          4 => [9, 10, 15, 16, 21],
          4.5 => [16, 17, 21, 22],
          5 => [17, 22, 23],
          5.5 => [21, 22],
        }.freeze

        EDGE0_TO_EDGE_LINE_REGIONS = {
          0 => [21],
          0.5 => [21],
          1 => [13, 14, 15, 21],
          1.5 => [14, 15, 21],
          2 => [6, 7, 14, 15, 21],
          2.5 => [7, 14, 15, 21],
          3 => [2, 8, 15, 21],
          3.5 => [9, 15, 16, 21],
          4 => [9, 10, 15, 16, 21],
          4.5 => [15, 16, 21],
          5 => [15, 16, 17, 21],
          5.5 => [21],
        }.freeze

        EDGE0P5_TO_EDGE_LINE_REGIONS = {
          0.0 => [21],
          0.5 => [21],
          1.0 => [13],
          1.5 => [13, 14],
          2.0 => [6, 7, 14],
          2.5 => [7, 14],
          3.0 => [2, 7, 8, 14],
          3.5 => [8, 9, 14, 15],
          4.0 => [9, 10, 15, 16],
          4.5 => [15, 16],
          5.0 => [15, 16, 17],
          5.5 => [15, 21],
        }.freeze

        # result of rotating tile one position clockwise
        CW_REGION = {
          0 => 3,
          1 => 4,
          2 => 10,
          3 => 11,
          4 => 18,
          5 => 1,
          6 => 2,
          7 => 8,
          8 => 9,
          9 => 16,
          10 => 17,
          11 => 23,
          12 => 0,
          13 => 6,
          14 => 7,
          15 => 14,
          16 => 15,
          17 => 21,
          18 => 22,
          19 => 5,
          20 => 12,
          21 => 13,
          22 => 19,
          23 => 20,
        }.freeze

        def regions(edge0, edge1, bezier, exit0)
          exit0 = !!exit0
          @@regions ||= {}
          @@regions["#{edge0}_#{edge1}_#{bezier}_#{exit0}"] ||= calculate_regions(edge0, edge1, bezier, exit0)
        end

        def calculate_regions(edge0, edge1, bezier, exit0)
          # assume can never have edge1=edge, edg0=non-edge
          if edge0.to_f != edge0.to_i.to_f
            # assume if edge0 is non-integer, then must be a line, no exits
            rot_edge1 = ((edge1 - edge0) + 0.5) % 6
            rot_regions = EDGE0P5_TO_EDGE_LINE_REGIONS[rot_edge1]
          else
            rot_edge1 = (edge1 - edge0) % 6
            rot_regions = if exit0 && bezier
                            EXIT0_TO_EDGE_BEZIER_REGIONS[rot_edge1]
                          elsif exit0 && !bezier
                            EXIT0_TO_EDGE_LINE_REGIONS[rot_edge1]
                          else
                            EDGE0_TO_EDGE_LINE_REGIONS[rot_edge1]
                          end
          end
          rotate_regions(rot_regions, edge0)
        end

        def rotate_regions(regions, rot)
          while rot > 0.5
            regions = regions.map { |r| CW_REGION[r] }
            rot -= 1
          end
          regions
        end

        def edge_x_pos(edge, distance)
          @@edge_x_pos ||= {}
          @@edge_x_pos["#{edge}_#{distance}"] ||= (-Math.sin((edge * 60) / 180 * Math::PI) * distance).round(2)
        end

        def edge_y_pos(edge, distance)
          @@edge_y_pos ||= {}
          @@edge_y_pos["#{edge}_#{distance}"] ||= (Math.cos((edge * 60) / 180 * Math::PI) * distance).round(2)
        end

        def control_location(begin_x, begin_y, end_x, end_y, edge)
          @@control_location ||= {}
          key = "#{begin_x}_#{begin_y}_#{end_x}_#{end_y}"
          @@control_location[key] ||= calculate_control_location(begin_x, begin_y, end_x, end_y, edge)
        end

        def calculate_control_location(begin_x, begin_y, end_x, end_y, edge)
          # calculate the position of the quadratic control point for a bezier curve to
          # be drawn between two points on a tile. If a point is on an edge, the control
          # point will be chosen to make the curve perpendicular to the tile edge.
          #

          # Currently this only handles the case where the start point is on an edge
          edge_perp_angle = EDGE_PERP_ANGLES[edge]

          distance = Math.sqrt((begin_x - end_x)**2 + (begin_y - end_y)**2)
          mid_x = (begin_x + end_x) / 2
          mid_y = (end_y + begin_y) / 2
          angle = Math.atan2(begin_y - end_y, end_x - begin_x)

          normal_angle = Math.atan2(end_x - begin_x, end_y - begin_y)

          # determine what side of curve control point should be on
          # -> want to always arc into the center of tile
          center_angle = Math.atan2(begin_y, -begin_x)
          normal_angle -= Math::PI if (angle >= 0 && center_angle < angle && angle - Math::PI < center_angle) ||
            (angle.negative? && center_angle < angle) ||
            (angle.negative? && Math::PI + angle < center_angle)

          internal_angle = edge_perp_angle / 180 * Math::PI - angle
          offset = (distance / 2 * Math.tan(internal_angle)).abs

          {
            x: (mid_x + Math.cos(normal_angle) * offset).round(2),
            y: (mid_y - Math.sin(normal_angle) * offset).round(2),
          }
        end

        def calculate_stop_x(ct_edge, tile)
          full_distance = 50
          full_distance -= 15 if tile.borders.any? { |border| border.edge == @ct_edge }
          edge_x_pos(ct_edge, full_distance)
        end

        def calculate_stop_y(ct_edge, tile)
          full_distance = 50
          full_distance -= 15 if tile.borders.any? { |border| border.edge == @ct_edge }
          edge_y_pos(ct_edge, full_distance)
        end

        def load_from_tile
          @terminal = @path.terminal
          @junction = @path.junction
          @exit = @path.edges.any?
          # for now assumes one edge and one node on path
          @edge = @path.edges.first.num

          @stop = @path.stop
          @ct_edge = @tile.preferred_city_town_edges[@stop] if @stop
          @center = @junction || (@stop && !@ct_edge)

          @begin_x = edge_x_pos(@edge, 87)
          @begin_y = edge_y_pos(@edge, 87)

          @end_x = @center ? 0 : calculate_stop_x(@ct_edge, @tile)
          @end_y = @center ? 0 : calculate_stop_y(@ct_edge, @tile)

          @need_bezier = !@center && @ct_edge != @edge && (@ct_edge - @edge).abs != 3

          @control_location = control_location(
            @begin_x,
            @begin_y,
            @end_x,
            @end_y,
            @edge
          ) if @need_bezier
        end

        def preferred_render_locations
          [
            {
              region_weights: @center ? EDGE_REGIONS[@edge] : regions(@edge, @ct_edge, @need_bezier, @exit),
              x: 0,
              y: 0,
            },
          ]
        end

        def render_part
          rotation = 60 * @edge

          props = {
            attrs: {
              d: "M #{@begin_x} #{@begin_y} "\
                 "L #{@end_x} #{@end_y}",
              stroke: @color,
              'stroke-width': @width,
              'stroke-dasharray': @dash,
            },
          }

          props[:attrs].merge!(
            d: "M #{@begin_x} #{@begin_y} "\
            "Q #{@control_location[:x]} #{@control_location[:y]} "\
            "#{@end_x} #{@end_y}",
          ) if @need_bezier

          # terminal tapered track only supported for centered city/town
          props[:attrs].merge!(
            transform: "rotate(#{rotation})",
            d: 'M6 60 L 6 85 L -6 85 L -6 60 L 0 25 Z',
            fill: @color,
            stroke: 'none',
            'stroke-linecap': 'butt',
            'stroke-linejoin': 'miter',
            'stroke-width': (@width.to_i * 0.75).to_s,
            'stroke-dasharray': @dash,
          ) if @terminal

          h(:path, props)
        end
      end
    end
  end
end
