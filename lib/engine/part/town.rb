# frozen_string_literal: true

require 'engine/part/base'
require 'engine/part/revenue_center'

module Engine
  module Part
    class Town < Base
      include Part::RevenueCenter

      attr_reader :local_id, :revenue

      def initialize(revenue, local_id = 0)
        @local_id = local_id.to_i
        @revenue = parse_revenue(revenue)
      end

      def ==(other)
        other.town? && (@revenue == other.revenue) && (@local_id == other.local_id)
      end

      def <=(other)
        other.town? && (@local_id == other.local_id)
      end

      def town?
        true
      end
    end
  end
end
