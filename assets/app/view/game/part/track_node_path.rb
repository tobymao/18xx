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

        def load_from_tile
          # for now assumes one edge and one node on path
          @edge = @path.edges.first.num
          @terminal = @path.terminal
          @junction = @path.junction
          return unless @path.stop

          @stop = @path.stop
          @ct_edge = @tile.preferred_city_town_edges[@stop]
        end

        def begin_location
          {
            x: -Math.sin((@edge * 60) / 180 * Math::PI) * 87,
            y: Math.cos((@edge * 60) / 180 * Math::PI) * 87,
          }
        end

        def end_location
          return { x: 0, y: 0 } if @junction

          if (@tile.towns.size + @tile.cities.size) < 2
            # this really needs to be stored in the city/town object
            full_distance = 0
          else
            full_distance = 50
            full_distance -= 15 if @tile.borders.any? { |border| border.edge == @ct_edge }
          end
          {
            x: -Math.sin((@ct_edge * 60) / 180 * Math::PI) * full_distance,
            y: Math.cos((@ct_edge * 60) / 180 * Math::PI) * full_distance,
          }
        end

        def control_location
          # calculate the position of the quadratic control point for a bezier curve to
          # be drawn between two points on a tile. If a point is on an edge, the control
          # point will be chosen to make the curve perpendicular to the tile edge.
          #
          loc0 = begin_location
          loc1 = end_location

          # Currently this only handles the case where the start poing is on an edge
          edge_perp_angle = EDGE_PERP_ANGLES[@edge]

          distance = Math.sqrt((loc0[:x] - loc1[:x])**2 + (loc0[:y] - loc1[:y])**2)
          mid = { x: (loc0[:x] + loc1[:x]) / 2, y: (loc1[:y] + loc0[:y]) / 2 }
          angle = Math.atan2(loc0[:y] - loc1[:y], loc1[:x] - loc0[:x])

          normal_angle = Math.atan2(loc1[:x] - loc0[:x], loc1[:y] - loc0[:y])

          # determine what side of curve control point should be on
          # -> want to always rc into the center of tile
          center_angle = Math.atan2(loc0[:y], -loc0[:x])
          if (angle >= 0) && (center_angle < angle) && ((angle - Math::PI) < center_angle)
            normal_angle -= Math::PI
          elsif angle.negative? && (center_angle < angle)
            normal_angle -= Math::PI
          elsif angle.negative? && ((Math::PI + angle) < center_angle)
            normal_angle -= Math::PI
          end

          internal_angle = edge_perp_angle / 180 * Math::PI - angle
          offset = (distance / 2 * Math.tan(internal_angle)).abs

          {
            x: mid[:x] + Math.cos(normal_angle) * offset,
            y: mid[:y] - Math.sin(normal_angle) * offset,
          }
        end

        def need_bezier?
          # probably not general enough
          (end_location != { x: 0, y: 0 }) && ((@ct_edge != @edge) && ((@ct_edge - @edge).abs != 3))
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
              d: "M #{begin_location[:x].round(2)} #{begin_location[:y].round(2)} "\
                 "L #{end_location[:x].round(2)} #{end_location[:y].round(2)}",
              stroke: @color,
              'stroke-width': @width,
              'stroke-dasharray': @dash,
            },
          }

          props[:attrs].merge!(
              d: "M #{begin_location[:x].round(2)} #{begin_location[:y].round(2)} "\
                 "Q #{control_location[:x].round(2)} #{control_location[:y].round(2)} "\
                 "#{end_location[:x].round(2)} #{end_location[:y].round(2)}",
            ) if need_bezier?

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
