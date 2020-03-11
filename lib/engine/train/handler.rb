# frozen_string_literal: true

module Engine
  module Train
    class Handler
      attr_reader :trains

      def initialize(trains, bank:)
        @trains = trains
        @bank = bank
      end

      def cash
        @bank.cash
      end

      def cash=(new_cash)
        @bank.cash = new_cash
      end
    end
  end
end
