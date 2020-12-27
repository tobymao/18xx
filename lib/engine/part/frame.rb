# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Frame < Base
      attr_reader :color

      def initialize(color)
        @color = color
      end

      def frame?
        true
      end
    end
  end
end
