# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Stripes < Base
      attr_accessor :color

      def initialize(color)
        @color = color
      end

      def stripes?
        true
      end
    end
  end
end
