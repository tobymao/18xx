# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Edge < Base
      attr_accessor :lanes, :num

      def id
        @ident ||= "#{hex.id}_#{@num}_#{@lanes[1]}"
      end

      def initialize(num)
        @num = num.to_i
      end

      def <=(other)
        other.edge? && (@num == other.num)
      end

      def edge?
        true
      end

      def rotate(ticks)
        edge = Edge.new((@num + ticks) % 6)
        edge.index = index
        edge.tile = @tile
        edge.lanes = @lanes
        edge
      end
    end
  end
end
