# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class City < Base
      attr_reader :name, :revenue, :slots

      def initialize(revenue, slots = 1, name = nil)
        @revenue = revenue.to_i
        @slots = slots.to_i
        @name = name
      end

      def ==(other)
        other.city? && (@revenue == other.revenue) && (@slots == other.slots) && (@name == other.name)
      end

      def city?
        true
      end
    end
  end
end
