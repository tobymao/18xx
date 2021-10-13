# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Frame < Base
      attr_reader :color, :color2

      def initialize(color, color2 = nil)
        @color = color
        @color2 = color2
      end

      def frame?
        true
      end
    end
  end
end
