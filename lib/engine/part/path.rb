# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :branch, :city, :edges, :junction, :node, :offboard, :stop, :town

      def initialize(a, b)
        @a = a
        @b = b
        @edges = []

        separate_parts
      end

      def matches(other)
        other&.path? &&
          ((@a.matches(other.a) && @b.matches(other.b)) ||
           (@a.matches(other.b) && @b.matches(other.a)))
      end

      def <=(other)
        (@a <= other.a && @b <= other.b) ||
          (@a <= other.b && @b <= other.a)
      end

      def path?
        true
      end

      def exits
        @edges.map(&:num)
      end

      def rotate(ticks)
        path = Path.new(@a.rotate(ticks), @b.rotate(ticks))
        path.tile = @tile
        path
      end

      def inspect
        name = self.class.name.split('::').last
        "<#{name}: hex: #{hex&.name}, exit: #{exits}"
      end

      private

      def separate_parts
        [@a, @b].each do |part|
          case
          when part.edge?
            @edges << part
          when part.offboard?
            @offboard = part
            @stop = part
            @node = part
          when part.city?
            @city = part
            @branch = part
            @stop = part
            @node = part
          when part.junction?
            @junction = part
            @branch = part
            @node = part
          when part.town?
            @town = part
            @branch = part
            @stop = part
            @node = part
          end
        end
      end
    end
  end
end
