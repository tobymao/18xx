# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Border < Base
      attr_reader :edge, :cost, :type, :color

      def initialize(edge, type = nil, cost = nil, color = nil)
        @edge = edge.to_i
        @type = type&.to_sym
        @cost = cost&.to_i
        @color = color&.to_sym
      end

      def border?
        true
      end
    end
  end
end
