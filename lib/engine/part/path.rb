# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :gauge, :branch, :city, :edges, :junction, :offboard, :stop, :town

      def initialize(a, b, gauge)
        @a = a
        @b = b
        @gauge = gauge || :broad
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
        Path.new(@a.rotate(ticks), @b.rotate(ticks), @gauge)
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
          when part.city?
            @city = part
            @branch = part
            @stop = part
          when part.junction?
            @junction = part
            @branch = part
          when part.town?
            @town = part
            @branch = part
            @stop = part
          end
        end
      end
    end
  end
end
