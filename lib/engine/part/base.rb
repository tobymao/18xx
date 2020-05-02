# frozen_string_literal: true

module Engine
  module Part
    class Base
      attr_accessor :index, :tile

      def id
        "#{tile.id}-#{index}"
      end

      def hex
        @tile&.hex
      end

      def <=>(other)
        if edge? && other.edge?
          num <=> other.num
        elsif edge?
          -1
        elsif other.edge?
          1
        else
          0
        end
      end

      def <=(other)
        self.matches?(other)
      end

      def rotate(_ticks)
        self
      end

      def blocks?(_corporation)
        false
      end

      def city?
        false
      end

      def edge?
        false
      end

      def junction?
        false
      end

      def label?
        false
      end

      def path?
        false
      end

      def town?
        false
      end

      def upgrade?
        false
      end

      def offboard?
        false
      end

      def inspect
        "<#{self.class.name}: hex: #{hex&.name}>"
      end
    end
  end
end
