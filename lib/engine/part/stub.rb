# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Stub < Base
      attr_reader :edge

      def initialize(edge)
        @edge = edge
      end

      def stub?
        true
      end

      def track
        :broad
      end
    end
  end
end
