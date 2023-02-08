# frozen_string_literal: true

require 'lib/settings'
require 'view/game/part/base'
require 'view/game/part/town_location'

module View
  module Game
    module Part
      class TrackNodePath < Base
        include TownLocation
        include Lib::Settings

        needs :tile
        needs :path
        needs :color, default: 'black'
        needs :width, default: 8
        needs :dash, default: '0'
        needs :pass, default: 1
        needs :border_props, default: nil
        needs :inner_props, default: nil

        STRAIGHT_CROSSOVER = '1 55 63 56'
        GENTLE_CROSSOVER = '1 55 47 56'

        PARALLEL_SPACING = [8, 7, 6].freeze

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

        def regions(edge0, edge1, arc, exit0)
          exit0 = !!exit0
          @@regions ||= {}
          @@regions["#{edge0}_#{edge1}_#{arc}_#{exit0}"] ||= calculate_regions(edge0, edge1, arc, exit0)
        end

        def calculate_regions(edge0, edge1, arc, exit0)
          # assume can never have edge1=edge, edge0=non-edge
          if !edge0
            CENTER
          elsif edge0 % 1 != 0
            # assume if edge0 is non-integer, then must be a line, no exits
            rot_edge1 = ((edge1 - edge0) + 0.5) % 6
            rot_regions = EDGE0P5_TO_EDGE_LINE_REGIONS[rot_edge1]
          else
            rot_edge1 = (edge1 - edge0) % 6
            rot_regions = if exit0 && arc
                            EXIT0_TO_EDGE_BEZIER_REGIONS[rot_edge1]
                          elsif exit0 && !arc
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

        def arc_parameters(begin_x, begin_y, end_x, end_y)
          @@arc_parameters ||= {}
          key = "#{begin_x}_#{begin_y}_#{end_x}_#{end_y}"
          @@arc_parameters[key] ||= calculate_arc_parameters(begin_x, begin_y, end_x, end_y)
        end

        # calculate radius and sweep
        def calculate_arc_parameters(begin_x, begin_y, end_x, end_y)
          distance = Math.sqrt(((begin_x - end_x)**2) + ((begin_y - end_y)**2))
          angle_b_o = Math.atan2(begin_y, -begin_x)
          angle_b_e = Math.atan2(begin_y - end_y, end_x - begin_x)
          angle_e_b_o = angle_b_o - angle_b_e
          if angle_e_b_o < -Math::PI
            angle_e_b_o += 2 * Math::PI
          elsif angle_e_b_o > Math::PI
            angle_e_b_o -= 2 * Math::PI
          end

          radius = (distance / (2.0 * Math.cos((Math::PI / 2.0) - angle_e_b_o.abs))).round(2)
          sweep = angle_e_b_o.negative? ? 0 : 1
          {
            radius: radius,
            sweep: sweep,
          }
        end

        def calculate_shift(lane)
          ((lane[1] * 2) - lane[0] + 1) * (@width.to_i + PARALLEL_SPACING[lane[0] - 2]) / 2.0
        end

        def calculate_stop_x(ct_edge, tile)
          return 0 unless ct_edge

          full_distance = 50
          full_distance -= 15 if tile.borders.any? { |border| border.edge == ct_edge }
          edge_x_pos(ct_edge, full_distance)
        end

        def calculate_stop_y(ct_edge, tile)
          return 0 unless ct_edge

          full_distance = 50
          full_distance -= 15 if tile.borders.any? { |border| border.edge == ct_edge }
          edge_y_pos(ct_edge, full_distance)
        end

        def calculate_townrect_xy(ct_edge, town)
          return [0, 0] unless ct_edge

          edges = normalized_edges(ct_edge, town.exits)
          _weights, x, y, _angle = town_position(@tile, town, edges).first
          [x.round(2), y.round(2)]
        end

        def colinear?(x0, y0, x1, y1)
          @@colinear ||= {}
          @@colinear["#{x0}_#{y0}_#{x1}_#{y1}"] ||=
            begin
              angle_be = Math.atan2(y1 - y0, x1 - x0)
              angle_bcenter = Math.atan2(-y0, -x0)
              (angle_be - angle_bcenter).abs < 0.05
            end
        end

        def load_from_tile
          @terminal = @path.terminal
          @junction = @path.junction
          @exit = @path.edges.any?
          @num_cts = @path.stops.size
          @num_exits = @path.edges.size
          @track = @path.track

          @stop0 = @path.stops.first
          @stop1 = @path.stops.last if @num_cts > 1
          @ct_edge0 = @tile.preferred_city_town_edges[@stop0] if @num_cts.positive?
          @ct_edge1 = @tile.preferred_city_town_edges[@stop1] if @num_cts > 1

          # these are the only possibilities this Class will handle:
          # 1. exit - exit
          # 2. exit - junction
          # 3. exit - city/town
          # 4. city/town - city/town

          if @num_exits > 1
            # exit - exit

            @begin_edge = @path.exits[0]
            @begin_x = edge_x_pos(@begin_edge, 87)
            @begin_y = edge_y_pos(@begin_edge, 87)

            @end_edge = @path.edges.last.num
            @end_x = edge_x_pos(@end_edge, 87)
            @end_y = edge_y_pos(@end_edge, 87)
            lanes = @path.lanes

            if @tile.crossover? && @path.straight?
              @crossover_dash = STRAIGHT_CROSSOVER
            elsif @tile.crossover? && @path.gentle_curve?
              @crossover_dash = GENTLE_CROSSOVER
            end

          elsif @num_exits == 1
            @begin_edge = @path.exits[0]
            @begin_x = edge_x_pos(@begin_edge, 87)
            @begin_y = edge_y_pos(@begin_edge, 87)

            if @junction
              # exit - junction
              @end_edge = nil
              @end_x = 0
              @end_y = 0
            else
              # exit - city/town
              @ct_edge0 = @tile.preferred_city_town_edges[@stop0] if @stop0
              @end_edge = @ct_edge0
              @end_x, @end_y = if @stop0.rect?
                                 calculate_townrect_xy(@ct_edge0, @stop0)
                               else
                                 [
                                   calculate_stop_x(@ct_edge0, @tile),
                                   calculate_stop_y(@ct_edge0, @tile),
                                 ]
                               end
            end
            lanes = @path.lanes
            lanes.reverse! if @path.b.edge?

            if @tile.crossover? && @path.straight?
              @crossover_dash = STRAIGHT_CROSSOVER
            elsif @tile.crossover? && @path.gentle_curve?
              @crossover_dash = GENTLE_CROSSOVER
            end

          else
            # city/town - city/town
            @ct_edge0 = @tile.preferred_city_town_edges[@stop0] if @stop0
            @ct_edge1 = @tile.preferred_city_town_edges[@stop1] if @stop1

            if @ct_edge0
              @begin_edge = @ct_edge0
              @begin_x, @begin_y = if @stop0.rect?
                                     calculate_townrect_xy(@ct_edge0, @stop0)
                                   else
                                     [
                                       calculate_stop_x(@ct_edge0, @tile),
                                       calculate_stop_y(@ct_edge0, @tile),
                                     ]
                                   end
              @end_edge = @ct_edge1
              @end_x, @end_y = if @stop1.rect?
                                 calculate_townrect_xy(@ct_edge1, @stop1)
                               else
                                 [
                                   calculate_stop_x(@ct_edge1, @tile),
                                   calculate_stop_y(@ct_edge1, @tile),
                                 ]
                               end
              lanes = @path.lanes
              lanes.reverse! if @path.b == @stop0
            else
              @begin_edge = @ct_edge1
              @begin_x, @begin_y = if @stop1.rect?
                                     calculate_townrect_xy(@ct_edge1, @stop1)
                                   else
                                     [
                                       calculate_stop_x(@ct_edge1, @tile),
                                       calculate_stop_y(@ct_edge1, @tile),
                                     ]
                                   end
              @end_edge = @ct_edge0
              @end_x, @end_y = if @stop0.rect?
                                 calculate_townrect_xy(@ct_edge0, @stop0)
                               else
                                 [
                                   calculate_stop_x(@ct_edge0, @tile),
                                   calculate_stop_y(@ct_edge0, @tile),
                                 ]
                               end
              lanes = @path.lanes
              lanes.reverse! if @path.b == @stop1
            end
          end

          @center = !@end_edge

          @need_arc = !@center && @exit && !colinear?(@begin_x, @begin_y, @end_x, @end_y)

          if @need_arc
            @arc_parameters = arc_parameters(
              @begin_x,
              @begin_y,
              @end_x,
              @end_y
            )
          end

          return if @path.single? || (!@begin_edge && !@end_edge)

          begin_shift_edge = @begin_edge || @end_edge
          end_shift_edge = @end_edge || @begin_edge

          begin_lane, end_lane = lanes

          if begin_lane[0] > 1
            begin_shift = calculate_shift(begin_lane)
            begin_delta_x = (begin_shift * Math.cos(begin_shift_edge * 60.0 * Math::PI / 180.0)).round(2)
            begin_delta_y = (begin_shift * Math.sin(begin_shift_edge * 60.0 * Math::PI / 180.0)).round(2)

            @begin_x += begin_delta_x
            @begin_y += begin_delta_y
          end

          return unless end_lane[0] > 1

          end_shift = calculate_shift(end_lane)
          end_delta_x = (end_shift * Math.cos(end_shift_edge * 60.0 * Math::PI / 180.0)).round(2)
          end_delta_y = (end_shift * Math.sin(end_shift_edge * 60.0 * Math::PI / 180.0)).round(2)

          @end_x += end_delta_x
          @end_y += end_delta_y
        end

        def preferred_render_locations
          return [{ region_weights: [], x: 0, y: 0 }] unless @pass == 1

          [
            {
              region_weights: @center ? EDGE_REGIONS[@begin_edge] : regions(@begin_edge, @end_edge, @need_arc, @exit),
              x: 0,
              y: 0,
            },
          ]
        end

        def build_props(color, width, dash)
          rotation = 60 * @begin_edge

          props = {
            attrs: {
              d: "M #{@begin_x} #{@begin_y} "\
                 "L #{@end_x} #{@end_y}",
              stroke: color,
              'stroke-width': width,
              'stroke-dasharray': dash,
            },
          }

          if @need_arc
            props[:attrs][:d] = "M #{@begin_x} #{@begin_y} "\
                                "A #{@arc_parameters[:radius]} #{@arc_parameters[:radius]} "\
                                "0 0 #{@arc_parameters[:sweep]} #{@end_x} #{@end_y}"
          end

          # Calculate the correct x position of the terminal pointer
          d_width = width.to_i / 2
          terminal_start_x = d_width
          terminal_end_x = -d_width
          begin_lane, = @path.lanes
          if begin_lane[0] > 1
            begin_shift = calculate_shift(begin_lane)
            terminal_start_x += begin_shift
            terminal_end_x += begin_shift
          end
          point_x = (terminal_start_x + terminal_end_x) / 2

          # terminal tapered track only supported for centered city/town
          if @terminal
            props[:attrs].merge!(
              transform: "rotate(#{rotation})",
              d: "M #{terminal_start_x} 70 L #{terminal_start_x} 87 L #{terminal_end_x} 87 "\
                 "L #{terminal_end_x} 70 L #{point_x} 35 Z",
              fill: color,
              stroke: 'none',
              'stroke-linecap': 'butt',
              'stroke-linejoin': 'miter',
              'stroke-width': (width.to_i * 0.75).to_s,
              'stroke-dasharray': dash,
            )
            if @terminal == '2'
              props[:attrs][:d] = "M #{terminal_start_x} 85 L #{terminal_start_x} 87 L #{terminal_end_x} 87 "\
                                  "L #{terminal_end_x} 85 L #{point_x} 65 Z"
              props[:attrs][:fill] = '#707070'
            end
          end
          props
        end

        def render_part
          props = case @pass
                  when 0
                    build_props(@border_props['color'], @width + @border_props['width'], 0)
                  when 1
                    build_props(@color, @width, @dash)
                  else
                    build_props(@inner_props['color'], @width - @inner_props['width'], @inner_props['dash'])
                  end

          children = [h(:path, props)]

          if @crossover_dash && @pass == 2
            props[:attrs].merge!(
              stroke: @color,
              'stroke-width': @width,
              'stroke-dasharray': @crossover_dash,
              'stroke-dashoffset': 1,
            )
            children.prepend(h(:path, props))
          end

          if @crossover_dash && @pass.positive?
            props[:attrs].merge!(
              stroke: @border_props['color'],
              'stroke-width': @width + @border_props['width'],
              'stroke-dasharray': @crossover_dash,
              'stroke-dashoffset': 1,
            )
            children.prepend(h(:path, props))
          end
          children
        end
      end
    end
  end
end
