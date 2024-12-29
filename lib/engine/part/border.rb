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

      def ==(other)
        other.edge == edge && other.type == type && other.cost == cost && other.color == color
      end

      def border?
        true
      end

      def inspect
        "<#{self.class.name}: hex: #{hex&.name} edge: #{edge} type: #{type} cost: #{cost}>"
      end
    end
  end
end
