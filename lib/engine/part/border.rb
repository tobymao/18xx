# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Border < Base
      attr_reader :edge

      def initialize(edge)
        @edge = edge.to_i
      end

      def border?
        true
      end
    end
  end
end
