# frozen_string_literal: true

module Engine
  module Train
    class Depot
      attr_reader :upcoming

      def initialize(trains, bank:)
        trains.each { |train| train.owner = self }
        @upcoming = trains
        @discarded = []
        @bank = bank
      end

      def remove_train(train)
        @upcoming.delete(train)
        @discarded.delete(train)
      end

      def available
        @discarded + [@upcoming.first]
      end

      def cash
        @bank.cash
      end

      def cash=(new_cash)
        @bank.cash = new_cash
      end

      def name
        'The Depot'
      end
    end
  end
end
