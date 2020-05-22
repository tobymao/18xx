# frozen_string_literal: true

module Engine
  module Part
    module Node
      def clear!
        @paths = nil
        @exits = nil
      end

      def paths
        @paths ||= @tile.paths.select { |p| p.node == self }
      end

      def exits
        @exits ||= paths.flat_map(&:exits)
      end
    end
  end
end
