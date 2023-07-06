# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Stub < Base
      attr_reader :edge, :track

      def initialize(edge, track = :broad)
        @edge = edge
        @track = track
      end

      def stub?
        true
      end

      def inspect
        "<#{self.class.name} edge=#{@edge}>"
      end
    end
  end
end
