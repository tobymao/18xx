# frozen_string_literal: true

require_relative 'revenue_center'

module Engine
  module Part
    class Town < RevenueCenter
      def town?
        true
      end
    end
  end
end
