# frozen_string_literal: true

require 'engine/part/base'
require 'engine/part/revenue_center'

module Engine
  module Part
    class Town < Base
      include Part::RevenueCenter

      attr_reader :name, :revenue

      def initialize(revenue, name = nil)
        @name = name
        @revenue = parse_revenue(revenue)
      end

      def ==(other)
        other.town? && (@revenue == other.revenue) && (@name == other.name)
      end

      def <=(other)
        other.town? && (@name == other.name)
      end

      def town?
        true
      end
    end
  end
end
