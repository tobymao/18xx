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
        center = {
          region_weights: CENTER,
          x: 0,
          y: 0,
        }

        up24 = {
          region_weights: TOP_MIDDLE_ROW,
          x: 0,
          y: -(24 + delta_y),
        }

        down24 = {
          region_weights: BOTTOM_MIDDLE_ROW,
          x: 0,
          y: 24,
        }

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

        up63 = {
          region_weights_in: { TRACK_TO_EDGE_3 => 1,
                               TOP_ROW => 1 },
          region_weights_out: { TOP_ROW => 1 },
          x: 0,
          y: -(63 + delta_y),
        }

        up56 = {
          region_weights_in: { TRACK_TO_EDGE_3 => 1,
                               TOP_ROW => 1 },
          region_weights_out: { TOP_ROW => 1 },
          x: 0,
          y: -(56 + delta_y),
        }

        down55 = {
          region_weights_in: { TRACK_TO_EDGE_0 => 1,
                               BOTTOM_ROW => 1 },
          region_weights_out: { BOTTOM_ROW => 1 },
          x: 0,
          y: 55,
        }

        if @tile.offboards.any?
          return [
            center,
            up24,
            down24,
          ]
        end

        default = [
          center,
          up40,
          down40,
        ]

        if @tile.cities.size == 1
          case @tile.cities.first.slots
          when 3
            [
              down50,
              up63,
            ]
          when 4
            [
              up56,
              down55,
            ]
          else
            default
          end
        elsif @tile.cities.size > 1
          down55[:region_weights_in][BOTTOM_ROW] += 1
          up56[:region_weights_in][TOP_ROW] += 1

          [
            center,
            down55,
            up56,
          ]
        elsif @tile.towns.size == 1
          default + [up63, down55]
        else
          default
        end
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

      def render_background_box
        lines = @name_segments.size
        characters = @name_segments.map(&:size).max

        buffer_x = CHARACTER_WIDTH
        buffer_y = 4

        width = buffer_x + (characters * CHARACTER_WIDTH)
        height = buffer_y + (lines * LINE_HEIGHT)

        attrs = {
          height: height,
          width: width,
          fill: BACKGROUND_COLOR,
          'fill-opacity': BACKGROUND_OPACITY,
          stroke: 'none',
          x: -width / 2,
          y: -((buffer_y + LINE_HEIGHT) / 2),
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
