# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Part
    class Base
      include Helper::Type

      attr_accessor :index, :tile

      def id
        "#{tile.id}-#{index}"
      end

      def hex
        @tile&.hex
      end

      def <=(other)
        self.class == other.class
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

      def rotate(_ticks)
        self
      end

      def blocks?(_corporation)
        false
      end

      def tokened_by?(_corporation)
        false
      end

      def tokenable?(_corporation, *)
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

      def border?
        false
      end

      def inspect
        "<#{self.class.name}: hex: #{hex&.name}>"
      end
    end
  end
end
