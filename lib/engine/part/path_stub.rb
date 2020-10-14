# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class PathStub < Base
      attr_reader :edge

      def initialize(edge)
        @edge = edge
      end

      def path_stub?
        true
      end
    end
  end
end
