# frozen_string_literal: true

require_relative 'revenue_center'

module Engine
  module Part
    class Town < RevenueCenter
      def town?
        true
      end

      # render with a rectangle (as opposed to a dot) if
      # it has any paths and either it's not in the center or it is in the center
      # and has less than two exits and less than three paths
      def rect?
        paths.any? && paths.size < 3
      end
    end
  end
end
