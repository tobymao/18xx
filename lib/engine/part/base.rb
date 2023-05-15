# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Part
    class Base
      include Helper::Type

      attr_accessor :index, :tile, :loc

      def id
        @id ||= "#{tile.id}-#{index}"
      end

      def signature
        "#{hex&.id}-#{index}"
      end

      def hex
        @tile&.hex
      end

      def <=(other)
        instance_of?(other.class)
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

      def future_label?
        false
      end

      def path?
        false
      end

      def town?
        false
      end

      def halt?
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

      def icon?
        false
      end

      def blocks_lay?
        false
      end

      def stub?
        false
      end

      def frame?
        false
      end

      def stripes?
        false
      end

      def partition?
        false
      end

      def pass?
        false
      end

      def visit_cost
        0
      end

      def inspect
        "<#{self.class.name}: hex: #{hex&.name}>"
      end
    end
  end
end
