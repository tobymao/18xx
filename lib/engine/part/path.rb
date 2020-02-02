# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :cities, :edges, :junctions, :towns

      # rubocop:disable Naming/MethodParameterName
      def initialize(a, b)
        @a = a
        @b = b
        @cities = []
        @edges = []
        @junctions = []
        @towns = []

        separate_parts
      end
      # rubocop:enable Naming/MethodParameterName

      def ==(other)
        other.path? &&
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
        @exits ||= @edges.map(&:num)
      end

      def rotate(ticks)
        Path.new(@a.rotate(ticks), @b.rotate(ticks))
      end

      private

      def separate_parts
        [@a, @b].each do |part|
          if part.city?
            @cities << part
          elsif part.edge?
            @edges << part
          elsif part.junction?
            @junctions << part
          elsif part.town?
            @towns << part
          end
        end
      end
    end
  end
end
