# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class LocationName < Base
      LINE_HEIGHT = 15
      CHARACTER_WIDTH = 8
      BACKGROUND_COLOR = '#FFFFFF'
      BACKGROUND_OPACITY = '0.5'
      def preferred_render_locations
        top =
          begin
            y = if @name_segments.size > 1
                  54
                else
                  61
                end
            {
              region_weights_in: { TRACK_TO_EDGE_3 => 1,
                                   TOP_ROW => 2 },
              region_weights_out: { TOP_ROW => 1 },
              x: 0,
              y: -(y + delta_y),
            }
          end

        up40 = {
          region_weights_in: { TRACK_TO_EDGE_3 => 1,
                               UPPER_CENTER => 1,
                               [6, 10] => 0.25,
                               TOP_ROW => 0.1 },
          region_weights_out: { UPPER_CENTER => 1,
                                [6, 10] => 0.25 },
          x: 0,
          y: -(40 + delta_y),
        }

        up24 = {
          region_weights: TOP_MIDDLE_ROW,
          x: 0,
          y: -(24 + delta_y),
        }

        center = {
          region_weights: CENTER,
          x: 0,
          y: -delta_y / 2,
        }

        down24 = {
          region_weights: BOTTOM_MIDDLE_ROW,
          x: 0,
          y: 24,
        }

        down40 = {
          region_weights_in: { TRACK_TO_EDGE_0 => 1,
                               LOWER_CENTER => 1,
                               [13, 17] => 0.25,
                               BOTTOM_ROW => 0.1 },
          region_weights_out: { LOWER_CENTER => 1,
                                [13, 14, 16, 17] => 0.25 },
          x: 0,
          y: 40,
        }

        down50 = {
          region_weights_in: { TRACK_TO_EDGE_0 => 1,
                               BOTTOM_ROW => 0.1 },
          region_weights_out: { BOTTOM_ROW => 1 },
          x: 0,
          y: 50,
        }

        bottom =
          begin
            y = if @name_segments.size > 1
                  39
                else
                  56
                end
            {
              region_weights_in: { TRACK_TO_EDGE_0 => 1,
                                   BOTTOM_ROW => 1.5 },
              region_weights_out: { BOTTOM_ROW => 1 },
              x: 0,
              y: (y + delta_y),
            }
          end

        if @tile.offboards.any?
          return [
            center,
            up24,
            down24,
          ]
        end

        if @tile.towns.size == 1
          return [
            center,
            up40,
            down40,
          ]
        end

        if @tile.cities.size == 1
          return case @tile.cities.first.slots
                 when 3
                   [
                     down50,
                     top,
                   ]
                 when 4
                   [
                     top,
                     bottom,
                   ]
                 else
                   [
                     center,
                     up40,
                     down40,
                   ]
                 end
        end

        if (@tile.towns + @tile.cities).size > 1
          # if top and bottom edges are both used, we might end up rendering in
          # the middle, so try to shift out of the way of track
          if [0, 3].all? { |e| @tile.exits.include?(e) }
            width, = box_dimensions
            shift = 79 - (width / 2)
            delta_x =
              if [1, 2].all? { |e| @tile.exits.include?(e) }
                # track on both left edges, so shift to the right
                shift
              elsif [4, 5].all? { |e| @tile.exits.include?(e) }
                # track on both right edges, so shift to the left
                -shift
              end
            center[:x] += delta_x if delta_x
          end

          return begin
                   if @tile.exits.any?
                     [
                       center,
                       bottom,
                       top,
                     ]
                   else
                     [
                       center,
                       up40,
                       down40,
                     ]
                   end
                 end
        end

        []
      end

      def load_from_tile
        @name_segments = self.class.name_segments(@tile.location_name)
      end

      def render_part
        attrs = {
          fill: 'black',
          transform: "scale(1.1) #{translate}",
          'text-anchor': 'middle',
          'stroke-width': 0.5,
          'alignment-baseline': 'middle',
          'dominant-baseline': 'middle',
        }

        rendered_name = @name_segments.map.with_index do |segment, index|
          x = 0
          y = index * LINE_HEIGHT
          h(:text, { attrs: { transform: "translate(#{x} #{y})" } }, segment)
        end

        h(:g, { style: { 'pointer-events': 'none' }, attrs: attrs }, [
            render_background_box,
            *rendered_name
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
        else
          segments
        end
      end
    end
  end
end
