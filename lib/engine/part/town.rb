# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class Town < Base
      attr_reader :name, :revenue

      def initialize(revenue, name = nil)
        @name = name
        @revenue = revenue.to_i
      end

      def ==(other)
        other.town? && (@revenue == other.revenue) && (@name == other.name)
      end

      def town?
        true
      end
    end
  end
end
