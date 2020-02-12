# frozen_string_literal: true

require 'engine/part/base'
require 'engine/part/revenue_center'

module Engine
  module Part
    class Offboard < Base
      include Part::RevenueCenter

      def initialize(revenue)
        @revenue = parse_revenue(revenue)
      end

      def offboard?
        true
      end

      def ==(other)
        other.offboard? &&
          @revenue == other.revenue
      end
    end
  end
end
