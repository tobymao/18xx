# frozen_string_literal: true

require 'snabberb/component'

module View
  module Part
    class Base < Snabberb::Component
      needs :region_use

      def preferred_render_locations
        [
          {
            regions: {},
            transform: '',
          }
        ]
      end

      def transform
        @transform ||= render_location[:transform]
      end

      def increment_cost
        regions = render_location[:regions]
        regions = regions.keys.flatten if regions.is_a?(Hash)

        regions.each do |region|
          @region_use[region] += 1
        end
      end

      def render_location
        @render_location ||= preferred_render_locations.min_by.with_index do |t, i|
          [combined_cost(t[:regions], @region_use), i]
        end
      end

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

      def combined_cost(regions, region_use)
        region_weights =
          if regions.is_a?(Array)
            { regions => 1 }
          else
            regions
          end

        region_weights.reduce(0) do |memo, (regions_, weight)|
          memo + weight * regions_.reduce(0) { |m, r| m + region_use[r] }
        end
      end
    end
  end
end
