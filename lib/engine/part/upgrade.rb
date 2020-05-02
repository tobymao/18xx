# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Upgrade < Base
      attr_reader :cost, :terrains

      def initialize(cost, terrains = nil)
        @cost = cost.to_i
        @terrains = terrains&.map(&:to_sym) || []
      end

      def matches(other)
        other.upgrade? && (@cost == other.cost) && (@terrains == other.terrains)
      end

      def upgrade?
        true
      end

      def mountain?
        @mountain ||= @terrains.include?(:mountain)
      end

      def water?
        @water ||= @terrains.include?(:water)
      end
    end
  end
end
