# frozen_string_literal: true

require_relative 'revenue_center'

module Engine
  module Part
    class Town < RevenueCenter
      attr_reader :to_city, :boom

      def initialize(revenue, **opts)
        super

        @to_city = opts[:to_city]
        @boom = opts[:boom]
      end

      def <=(other)
        return true if to_city && other.city?

        super
      end

      def town?
        true
      end

      # render with a rectangle (as opposed to a dot) if
      # it has any paths and either it's not in the center or it is in the center
      # and has less than two exits and less than three paths
      def rect?
        paths.any? && paths.size < 3 && (@loc != 'center')
      end
    end
  end
end
