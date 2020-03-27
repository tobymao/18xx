# frozen_string_literal: true

require 'snabberb/component'

module View
  module Part
    class Base < Snabberb::Component
      needs :region_use
      needs :tile, default: nil

      UPPER_LEFT = [0, 1, 2].freeze
      UPPER_RIGHT = [2, 3, 4].freeze
      UPPER_CENTER = [6, 7, 8].freeze
      UPPER_CENTER_RIGHT = [8, 9, 10].freeze

      CENTER = [7, 8, 9, 14, 15, 16].freeze

      LEFT_CENTER = [7, 14].freeze
      RIGHT_CENTER = [9, 16].freeze

      LEFT_MID = [6, 13].freeze
      RIGHT_MID = [10, 17].freeze

      LEFT_CORNER = [5, 12].freeze
      RIGHT_CORNER = [11, 18].freeze

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
          }
        ]
      end

      def translate
        x = render_location[:x]
        y = render_location[:y]

        "translate(#{x} #{y})"
      end

      def increment_cost
        region_weights = render_location[:region_weights_out] || render_location[:region_weights]

        region_weights = { region_weights => 1.0 } if region_weights.is_a?(Array)

        region_weights.each do |regions, weight|
          regions.each do |region|
            @region_use[region] += weight
          end
        end
      end

      def render_location
        @render_location ||= preferred_render_locations.min_by.with_index do |t, i|
          [combined_cost(t[:region_weights_in] || t[:region_weights]), i]
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
    end
  end
end
