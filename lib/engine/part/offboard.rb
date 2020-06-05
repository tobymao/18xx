# frozen_string_literal: true

require_relative 'revenue_center'

module Engine
  module Part
    class Offboard < RevenueCenter
      def blocks?(_corporation)
        true
      end

      def offboard?
        true
      end
    end
  end
end
