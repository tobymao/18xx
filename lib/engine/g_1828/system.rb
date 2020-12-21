# frozen_string_literal: true

module Engine
  module G1828
    module System
      attr_reader :shells

      def setup
        @shells = [self]
        @always_market_price = true
      end

      def system?
        true
      end
    end
  end
end
