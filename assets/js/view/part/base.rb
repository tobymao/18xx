# frozen_string_literal: true

require 'snabberb/component'

module View
  module Part
    class Base < Snabberb::Component
      needs :region_use

      CENTER = [7, 8, 9, 14, 15, 16].freeze

      LEFT_CENTER = [6, 7, 13, 14].freeze
      RIGHT_CENTER = [9, 10, 16, 17].freeze

      LEFT_CORNER = [5, 12].freeze
      RIGHT_CORNER = [11, 18].freeze

      def preferred_render_locations
        [
          {
            region_weights: {},
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
        region_weights = render_location[:region_weights]
        region_weights = region_weights.keys.flatten

        region_weights.each do |region|
          @region_use[region] += 1
        end
      end

      def render_location
        @render_location ||= preferred_render_locations.min_by.with_index do |t, i|
          [combined_cost(t[:region_weights], @region_use), i]
        end
      end

      # use this method to set instance vars that can be used in the other
      # methods called by render
      def parse_tile; end

      def should_render?
        true
      end

      def render
        parse_tile

        return unless should_render?

        increment_cost

        render_part
      end

      def render_part
        raise NotImplementedError
      end

      def combined_cost(region_weights, region_use)
        region_weights.reduce(0) do |memo, (regions, weight)|
          memo + weight * regions.reduce(0) { |m, r| m + region_use[r] }
        end
      end
    end
  end
end
