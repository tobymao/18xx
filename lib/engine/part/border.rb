# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Border < Base
      attr_reader :edge, :cost, :type

      def initialize(edge, type = nil, cost = nil)
        @edge = edge.to_i
        @type = type&.to_sym
        @cost = cost&.to_i
      end

      def border?
        true
      end
    end
  end
end
