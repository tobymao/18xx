# frozen_string_literal: true

module Engine
  module G1828
    module System
      attr_reader :shells, :corporations

      def self.extended(base)
        base.instance_variable_set(:@always_market_price, true)
        base.instance_variable_set(:@shells, [])
        base.instance_variable_set(:@corporations, [])
      end

      def system?
        true
      end

      def name=(name)
        @name = name
      end

      def remove_train(train)
        super
        @shells.each { |shell| shell.trains.delete(train) }
      end
    end
  end
end
