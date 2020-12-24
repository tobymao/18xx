# frozen_string_literal: true

module Engine
  module G1828
    module System
      attr_reader :shells

      def self.extended(base)
        base.instance_variable_set(:@always_market_price, true)
        base.instance_variable_set(:@shells, [])
      end

      def system?
        true
      end

      def name=(name)
        @name = name
      end

      def trains_by_shell
        @shells.map(&:trains)
      end

      def trains
        trains_by_shell.flatten
      end
    end
  end
end
