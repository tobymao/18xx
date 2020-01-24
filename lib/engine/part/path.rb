# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b

      # rubocop:disable Naming/MethodParameterName
      def initialize(a, b)
        @a = a
        @b = b
      end
      # rubocop:enable Naming/MethodParameterName

      def ==(other)
        @a == other.a && @b == other.b
      end

      def path?
        true
      end
    end
  end
end
