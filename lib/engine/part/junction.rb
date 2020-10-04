# frozen_string_literal: true

require_relative 'node'

module Engine
  module Part
    class Junction < Base
      attr_accessor :lanes

      def ident
        self
      end

      def junction?
        true
      end

      def clear!
        @paths = nil
        @exits = nil
      end

      def paths
        @paths ||= @tile.paths.select { |p| p.junction == self }
      end

      def exits
        @exits ||= paths.flat_map(&:exits)
      end
    end
  end
end
