# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Stub < Base
      attr_reader :edge, :owner

      def initialize(edge, owner: nil)
        @edge = edge
        @owner = owner
      end

      def stub?
        true
      end

      def track
        :broad
      end

      def inspect
        "<#{self.class.name} edge=#{@edge}>"
      end
    end
  end
end
