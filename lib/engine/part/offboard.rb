# frozen_string_literal: true

require_relative 'base'
require_relative 'node'
require_relative 'revenue_center'

module Engine
  module Part
    class Offboard < Base
      include Node
      include RevenueCenter

      def initialize(revenue)
        @revenue = parse_revenue(revenue)
      end

      def blocks?(_corporation)
        true
      end

      def offboard?
        true
      end
    end
  end
end
