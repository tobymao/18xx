# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :branch, :city, :edges, :junction, :offboard, :town

      def initialize(a, b)
        @a = a
        @b = b
        @edges = []

        separate_parts
      end

      def ==(other)
        other&.path? &&
          ((@a == other.a && @b == other.b) ||
           (@a == other.b && @b == other.a))
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
        Path.new(@a.rotate(ticks), @b.rotate(ticks))
      end

      private

      def separate_parts
        [@a, @b].each do |part|
          next @edges << part if part.edge?
          next @offboard = part if part.offboard?

          @branch = part

          if part.city?
            @city = part
          elsif part.junction?
            @junction = part
          elsif part.town?
            @town = part
          end
        end
      end
    end
  end
end
