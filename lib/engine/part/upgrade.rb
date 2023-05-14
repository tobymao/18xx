# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Upgrade < Base
      attr_reader :cost, :terrains, :size

      def initialize(cost, terrains = nil, size = nil, loc: nil)
        @cost = cost.to_i
        @terrains = terrains&.map(&:to_sym) || []
        @size = size&.to_i
        @loc = loc
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
