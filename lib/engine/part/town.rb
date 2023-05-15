# frozen_string_literal: true

require_relative 'revenue_center'

module Engine
  module Part
    class Town < RevenueCenter
      attr_accessor :style
      attr_reader :to_city, :boom

      def initialize(revenue, **opts)
        super

        @to_city = opts[:to_city]
        @boom = opts[:boom]
        @style = opts[:style]&.to_sym
      end

      def <=(other)
        return true if to_city && other.city?

        super
      end

      def town?
        true
      end

      # render as a dot or rectangle; if @style is set to 'rect', then render a
      # rectangle; if @style is set to something else, render a dot; if @style is
      # unset, render with a rectangle if it has any paths and either it's not
      # in the center or it is in the center and has less than two exits and
      # less than three paths
      def rect?
        @style ? (@style == :rect) : (!paths.empty? && paths.size < 3)
      end

      def hidden?
        @style == :hidden
      end
    end
  end
end
