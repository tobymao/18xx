# frozen_string_literal: true

module Engine
  module Part
    class Base
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
    end
  end
end
