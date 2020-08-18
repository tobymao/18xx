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
          1 => TRACK_TO_EDGE_1,
          2 => TRACK_TO_EDGE_2,
          3 => TRACK_TO_EDGE_3,
          4 => TRACK_TO_EDGE_4,
          5 => TRACK_TO_EDGE_5,
        }.freeze

        def self.lookup_pos_x(edge, distance)
          @@edge_x ||= {}
          @@edge_x["#{edge}_#{distance}"] ||= (-Math.sin((edge * 60) / 180 * Math::PI) * distance).round(2)
        end

        def self.lookup_pos_y(edge, distance)
          @@edge_y ||= {}
          @@edge_y["#{edge}_#{distance}"] ||= (Math.cos((edge * 60) / 180 * Math::PI) * distance).round(2)
        end

        def self.lookup_control_location(begin_x, begin_y, end_x, end_y, edge)
          @@control_location ||= {}
          key = "#{begin_x}_#{begin_y}_#{end_x}_#{end_y}"
          @@control_location[key] ||= TrackNodePath.calculate_control_location(begin_x, begin_y, end_x, end_y, edge)
        end

        def self.calculate_control_location(begin_x, begin_y, end_x, end_y, edge)
          # calculate the position of the quadratic control point for a bezier curve to
          # be drawn between two points on a tile. If a point is on an edge, the control
          # point will be chosen to make the curve perpendicular to the tile edge.
          #

          # Currently this only handles the case where the start point is on an edge
          edge_perp_angle = EDGE_PERP_ANGLES[edge]

          distance = Math.sqrt((begin_x - end_x)**2 + (begin_y - end_y)**2)
          mid = { x: (begin_x + end_x) / 2, y: (end_y + begin_y) / 2 }
          angle = Math.atan2(begin_y - end_y, end_x - begin_x)

          normal_angle = Math.atan2(end_x - begin_x, end_y - begin_y)

          # determine what side of curve control point should be on
          # -> want to always arc into the center of tile
          center_angle = Math.atan2(begin_y, -begin_x)
          normal_angle -= Math::PI if (angle >= 0) && (center_angle < angle) && ((angle - Math::PI) < center_angle) ||
                                      angle.negative? && (center_angle < angle) ||
                                      angle.negative? && ((Math::PI + angle) < center_angle)

          internal_angle = edge_perp_angle / 180 * Math::PI - angle
          offset = (distance / 2 * Math.tan(internal_angle)).abs

          {
            x: (mid[:x] + Math.cos(normal_angle) * offset).round(2),
            y: (mid[:y] - Math.sin(normal_angle) * offset).round(2),
          }
        end

        def calculate_stop_x(ct_edge, tile)
          full_distance = 50
          full_distance -= 15 if tile.borders.any? { |border| border.edge == @ct_edge }
          TrackNodePath.lookup_pos_x(ct_edge, full_distance)
        end

        def calculate_stop_y(ct_edge, tile)
          full_distance = 50
          full_distance -= 15 if tile.borders.any? { |border| border.edge == @ct_edge }
          TrackNodePath.lookup_pos_y(ct_edge, full_distance)
        end

        def load_from_tile
          # for now assumes one edge and one node on path
          @edge = @path.edges.first.num
          @terminal = @path.terminal
          @junction = @path.junction

          @stop = @path.stop
          @ct_edge = @tile.preferred_city_town_edges[@stop] if @stop
          @center = @junction || (@tile.towns.size + @tile.cities.size) < 2

          @begin_x = TrackNodePath.lookup_pos_x(@edge, 87)
          @begin_y = TrackNodePath.lookup_pos_y(@edge, 87)

          @end_x = @center ? 0 : calculate_stop_x(@ct_edge, @tile)
          @end_y = @center ? 0 : calculate_stop_y(@ct_edge, @tile)

          @need_bezier = !@center && (@ct_edge != @edge) && ((@ct_edge - @edge).abs != 3)
          @control_location = TrackNodePath.lookup_control_location(@begin_x, @begin_y,
                                                                    @end_x, @end_y, @edge) if @need_bezier
        end

        def preferred_render_locations
          [
            {
              region_weights: EDGE_REGIONS[@edge],
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
            'stroke-width': @width.to_i * 0.75,
            'stroke-dasharray': @dash,
          ) if @terminal

          [
            h(:path, props),
          ]
        end
      end
    end
  end
end
