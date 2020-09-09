# frozen_string_literal: true

require 'view/game/part/base'

module View
  module Game
    module Part
      class LocationName < Base
        LINE_HEIGHT = 15
        CHARACTER_WIDTH = 8
        BACKGROUND_COLOR = '#FFFFFF'
        BACKGROUND_OPACITY = '0.5'

        def preferred_render_locations
          return [l_center, l_up24, l_down24] if @tile.offboards.any?

          return [l_center, l_up40, l_down40] if @tile.towns.one? && @tile.cities.empty?

          if @tile.cities.one? && @tile.towns.empty?
            return case @tile.cities.first.slots
                   when 3
                     [l_down50, l_top]
                   when 4
                     [l_top, l_bottom]
                   else
                     [l_center, l_up40, l_down40]
                   end
          end

          if (@tile.towns + @tile.cities).size > 1
            center = l_center

            # if top and bottom edges are both used, we might end up rendering the
            # name in the middle, so try to shift out of the way of track
            if ([0, 3] - @tile.exits).empty?
              width, = box_dimensions
              shift = 79 - (width / 2)
              if ([1, 2] - @tile.exits).empty?
                center[:x] += shift
              elsif ([4, 5] - @tile.exits).empty?
                center[:x] - shift
              end
            end

            return [center, l_up40, l_down40] if @tile.exits.empty? && @tile.cities.empty?

            return [center, l_up40, l_down40, l_bottom, l_top]
          end

          []
        end

        def load_from_tile
          @name_segments = self.class.name_segments(@tile.location_name)
        end

        def render_part
          attrs = {
            transform: "scale(1.1) #{translate}",
            'stroke-width': 0.5,
          }

          rendered_name = @name_segments.map.with_index do |segment, index|
            x = 0
            y = index * LINE_HEIGHT + 1
            h(:text, { attrs: { transform: "translate(#{x} #{y})" } }, segment)
          end

          h(:g, { attrs: { transform: rotation_for_layout } }, [
            h('g.tile__text', { attrs: attrs }, [
              render_background_box,
              *rendered_name,
            ]),
          ])
        end

        def box_dimensions
          @box_dimensions ||=
            begin
              lines = @name_segments.size
              characters = @name_segments.map(&:size).max

              buffer_x = CHARACTER_WIDTH
              buffer_y = 4

              width = buffer_x + (characters * CHARACTER_WIDTH)
              height = buffer_y + (lines * LINE_HEIGHT)

              [width, height]
            end
        end

        def render_background_box
          width, height = box_dimensions

          attrs = {
            height: height,
            width: width,
            fill: BACKGROUND_COLOR,
            'fill-opacity': BACKGROUND_OPACITY,
            stroke: 'none',
            x: -width / 2,
            y: -(((CHARACTER_WIDTH / 2) + LINE_HEIGHT) / 2),
          }

          h(:rect, attrs: attrs)
        end

        # adjustment for translation based on the number of segments in the name
        #
        # currently only used when the name is rendered above center, as new lines
        # are added below the first one; names above center need to start higher
        # up, but names below center don't
        def delta_y
          @delta_y ||= (@name_segments.size - 1) * LINE_HEIGHT
        end

        # split the location name to render across multiple lines; each "segment"
        # that is returned gets rendered on its own line
        def self.name_segments(name, max_size: 13)
          return [name] if name.size <= max_size

          segments = name.split(' ')

          case segments.size
          when 3
            # join the middle word with the shorter of the first and last words;
            # prefer joining with first if the first and last words are the same
            # length
            if segments[0].size > segments[2].size
              [segments[0], segments[1..2].join(' ')]
            else
              [segments[0..1].join(' '), segments[2]]
            end
          when 4
            # join first two words together, and join last two words together
            segments.each_slice(2).map { |pair| pair.join(' ') }
          when 5
            # join the middle word with the shorter of the front or back 2 words
            front = segments[0..1].join(' ')
            back = segments[3..5].join(' ')
            if front.size > back.size
              [front + ' ' + segments[2], back]
            else
              [front, segments[2] + ' ' + back]
            end
          else
            segments
          end
        end

        private

        def l_top
          if layout == :flat
            y = @name_segments.size > 1 ? 54 : 61
            {
             region_weights_in: {
               TRACK_TO_EDGE_3 => 1,
               TOP_ROW => 2,
             },
             region_weights_out: { TOP_ROW => 1 },
             x: 0,
             y: -(y + delta_y),
            }
          elsif layout == :pointy
            y = @name_segments.size > 1 ? 63 : 70
            {
             region_weights: {
               [0, 1] => 1,
               [2, 3, 5, 6] => 0.5,
             },
             x: 0,
             y: -(y + delta_y),
            }
          end
        end

        def l_up40
          y = -(40 + delta_y)

          loc = { x: 0, y: y }

          if layout == :flat
            loc[:region_weights_in] = {
              TRACK_TO_EDGE_3 => 1,
              UPPER_CENTER => 1,
              [6, 10] => 0.25,
              TOP_ROW => 0.1,
            }
            loc[:region_weights_out] = { UPPER_CENTER => 1, [6, 10] => 0.25 }
          else
            # slight extra nudge to clear the revenue circle
            loc[:y] -= 2

            loc[:region_weights_in] = {
              TRACK_TO_EDGE_2 => 0.5,
              TRACK_TO_EDGE_3 => 0.5,
              [2, 6, 7, 8] => 1,
              [3, 5] => 0.25,
              [0, 1] => 0.1,
            }
            loc[:region_weights_out] = { [2, 6, 7, 8] => 1, [3, 5] => 0.25 }
          end
          loc
        end

        def l_up24
          loc = {
            x: 0,
            y: -(24 + delta_y),
          }
          loc[:region_weights] = layout == :flat ? TOP_MIDDLE_ROW : [2, 4, 6, 7, 8, 12]
          loc
        end

        def l_center
          {
            region_weights: CENTER,
            x: 0,
            y: -delta_y / 2,
          }
        end

        def l_down24
          loc = { x: 0, y: 24 }
          loc[:region_weights] = layout == :flat ? BOTTOM_MIDDLE_ROW : [11, 15, 16, 17, 19, 21]
          loc
        end

        def l_down40
          loc = { x: 0, y: 40 }

          if layout == :flat
            loc[:region_weights_in] = {
              TRACK_TO_EDGE_0 => 1,
              LOWER_CENTER => 1,
              [13, 17] => 0.25,
              BOTTOM_ROW => 0.1,
            }
            loc[:region_weights_out] = {
              LOWER_CENTER => 1,
              [13, 14, 16, 17] => 0.25,
            }
          elsif layout == :pointy
            loc[:region_weights_in] = {
              TRACK_TO_EDGE_0 => 0.5,
              TRACK_TO_EDGE_5 => 0.5,
              [15, 16, 21, 17] => 1,
              [11, 18, 19, 20] => 0.5,
              [22, 23] => 0.1,
            }
            loc[:region_weights_out] = { [15, 16, 21, 17] => 1, [11, 18, 19, 20] => 0.25 }
          end
          loc
        end

        def l_down50
          loc = { x: 0, y: 50 }

          loc[:region_weights_in] = { TRACK_TO_EDGE_0 => 1, BOTTOM_ROW => 0.1 }
          loc[:region_weights_out] = { BOTTOM_ROW => 1 }
          loc
        end

        def l_bottom
          y = if @name_segments.size > 1
                39
              else
                layout == :flat ? 56 : 65
              end

          loc = { x: 0, y: y + delta_y }

          if layout == :flat
            loc[:region_weights_in] = { TRACK_TO_EDGE_0 => 1, BOTTOM_ROW => 1.5 }
            loc[:region_weights_out] = { BOTTOM_ROW => 1 }
          elsif layout == :pointy
            loc[:region_weights] = {
              [22, 23] => 1,
              [17, 18, 20, 21] => 0.5,
            }
          end
          loc
        end
      end
    end
  end
end
