# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class Edge < Base
      attr_reader :num

      def initialize(num)
        @num = num.to_i
      end

      def ==(other)
        other.is_a?(Edge) && (@num == other.num)
      end

      def edge?
        true
      end
    end
  end
end
