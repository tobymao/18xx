# frozen_string_literal: true

require_relative 'town'

module Engine
  module Part
    class Halt < Town
      attr_reader :symbol

      def initialize(symbol, **opts)
        @symbol = symbol
        super('0', **opts)
      end

      def <=(other)
        return true if other.town?

        super
      end

      def halt?
        true
      end
    end
  end
end
