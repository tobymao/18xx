# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Edge < Base
      attr_accessor :num

      def initialize(num)
        @num = num.to_i
      end

      def matches?(other)
        other.edge? && (@num == other.num)
      end

      def edge?
        true
      end

      def rotate(ticks)
        edge = Edge.new((@num + ticks) % 6)
        edge.tile = @tile
        edge
      end
    end
  end
end
