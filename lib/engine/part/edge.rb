# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class Edge < Base
      attr_accessor :num

      def initialize(num)
        @num = num.to_i
      end

      def ==(other)
        other.edge? && (@num == other.num)
      end

      def edge?
        true
      end
    end
  end
end
