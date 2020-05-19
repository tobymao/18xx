# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Label < Base
      def initialize(label = nil)
        @label = label
      end

      def to_s
        @label.to_s
      end

      def ==(other)
        other&.label? && @label == other.to_s
      end

      def label?
        true
      end
    end
  end
end
