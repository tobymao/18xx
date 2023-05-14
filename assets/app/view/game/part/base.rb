# frozen_string_literal: true

module View
  module Game
    module Part
      class Base < Snabberb::Component
        needs :region_use
        needs :tile, default: nil
        needs :loc, default: nil

        UPPER_LEFT = [0, 1, 2].freeze
        UPPER_RIGHT = [2, 3, 4].freeze
        UPPER_CENTER_LEFT = [6, 7, 8].freeze
        UPPER_CENTER_RIGHT = [8, 9, 10].freeze

        UPPER_CENTER = [7, 8, 9].freeze
        LOWER_CENTER = [14, 15, 16].freeze

        CENTER = [7, 8, 9, 14, 15, 16].freeze

        LEFT_CENTER = [7, 14].freeze
        RIGHT_CENTER = [9, 16].freeze

        LEFT_MID = [6, 13].freeze
        RIGHT_MID = [10, 17].freeze

        LEFT_CORNER = [5, 12].freeze
        UPPER_LEFT_CORNER = [0, 1].freeze
        UPPER_RIGHT_CORNER = [3, 4].freeze
        RIGHT_CORNER = [11, 18].freeze
        BOTTOM_RIGHT_CORNER = [22, 23].freeze
        BOTTOM_LEFT_CORNER = [19, 20].freeze

        TRACK_TO_EDGE_0 = [15, 21].freeze
        TRACK_TO_EDGE_1 = [13, 14].freeze
        TRACK_TO_EDGE_2 = [6, 7].freeze
        TRACK_TO_EDGE_3 = [2, 8].freeze
        TRACK_TO_EDGE_4 = [9, 10].freeze
        TRACK_TO_EDGE_5 = [16, 17].freeze

        TRACK_TO_EDGE_0P5 = [14, 15, 19, 20].freeze
        TRACK_TO_EDGE_1P5 = [5, 7, 12, 4].freeze
        TRACK_TO_EDGE_2P5 = [0, 1, 7, 8].freeze
        TRACK_TO_EDGE_3P5 = [3, 4, 8, 9].freeze
        TRACK_TO_EDGE_4P5 = [9, 11, 16, 18].freeze
        TRACK_TO_EDGE_5P5 = [15, 16, 22, 23].freeze

        TOP_ROW = [0, 1, 2, 3, 4].freeze
        TOP_MIDDLE_ROW = [6, 7, 8, 9, 10].freeze
        BOTTOM_MIDDLE_ROW = [13, 14, 15, 16, 17].freeze
        BOTTOM_ROW = [19, 20, 21, 22, 23].freeze

        REGIONS_ROTATED_ONCE = {
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

        def preferred_render_locations
          [
            {
              # use this key to use the same weights for the specified regions
              # both when determining the cost of using those regions, and when
              # incrementing those costs
              #
              # Hash:
              #   - keys: Arr<Int>; list of regions
              #   - values: Float
              #
              # Alternatively, this may be just a list of regions, with implicit
              # weight 1.0
              region_weights: {},

              # use these keys to use different weights for the specified regions
              # when deciding where to render vs incrementing the cost of the
              # chosen regions
              #
              # - `region_weights_in` for determining the cost of rendering in
              #    those regions; in other words, the regions this part cares
              #    about having stuff in them
              #
              # - `region_weights_out` for determining how much to increment the
              #   cost of that region in @region_use, for future parts; in other
              #   words, the regions this part actually uses in rendering
              # Hash:
              #   - keys: Arr<Int>; list of regions
              #   - values: Float
              #
              # Alternatively, these may be just a list of regions, with implicit
              # weight 1.0
              region_weights_in: {},
              region_weights_out: {},

              # offset given to svg's translate()
              x: 0,
              y: 0,
            },
          ]
        end

        def translate
          x = render_location[:x]
          y = render_location[:y]

          "translate(#{x.round(2)} #{y.round(2)})"
        end

        def scale
          "scale(#{render_location[:scale] || 1})"
        end

        def rotation
          angle = render_location[:angle] || 0

          "rotate(#{angle})"
        end

        def increment_cost
          region_weights = render_location[:region_weights_out] || render_location[:region_weights]

          region_weights = { region_weights => 1.0 } if region_weights.is_a?(Array)

          region_weights.each do |regions, weight|
            increment_weight_for_regions(regions, weight)
          end
        end

        def increment_weight_for_regions(regions, weight = 1)
          regions.each do |region|
            @region_use[region] += weight
          end
        end

        def render_location
          @render_location ||=
            begin
              locations = @loc ? preferred_render_locations_by_loc : preferred_render_locations
              locations.min_by.with_index do |t, i|
                [combined_cost(t[:region_weights_in] || t[:region_weights]), i]
              end
            end
        end

        # use this method to set instance vars that can be used in the other
        # methods called by render
        def load_from_tile; end

        def should_render?
          true
        end

        def render
          load_from_tile

          return '' unless should_render?

          increment_cost

          render_part
        end

        def render_part
          raise NotImplementedError
        end

        def combined_cost(region_weights)
          region_weights = { region_weights => 1.0 } if region_weights.is_a?(Array)

          region_weights.sum do |regions, weight|
            weight * regions.sum { |region| @region_use[region] }
          end
        end

        def rotate_region(region, rotations: nil, degrees: nil)
          rotations ||= (degrees / 60).to_i

          (1..rotations).each do |_|
            region = REGIONS_ROTATED_ONCE[region]
          end
          region
        end

        def layout
          @layout ||= @tile&.hex&.layout
        end

        def angle_for_layout
          @angle_for_layout ||= layout == :pointy ? -30 : 0
        end

        def rotation_for_layout
          "rotate(#{angle_for_layout})"
        end
      end
    end
  end
end
