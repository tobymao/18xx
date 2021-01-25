# frozen_string_literal: true

require_relative '../corporation'
require_relative 'shell'

module Engine
  module G1828
    class System < Engine::Corporation
      attr_reader :shells, :corporations

      def initialize(sym:, name:, **opts)
        opts[:always_market_price] = true
        opts[:float_percent] = 50
        super(sym: sym, name: name, **opts)

        @corporations = opts[:corporations]
        @name = @corporations.first.name

        @shells = []
      end

      def system?
        true
      end

      def remove_train(train)
        @shells.each { |shell| shell.trains.delete(train) }
      end
    end
  end
end
