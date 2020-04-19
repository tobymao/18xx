# frozen_string_literal: true

module Engine
  module Train
    class Depot
      attr_reader :trains, :upcoming, :discarded

      def initialize(trains, bank:)
        @trains = trains
        @trains.each { |train| train.owner = self }
        @upcoming = @trains.dup
        @discarded = []
        @bank = bank
      end

      def reclaim_train(train)
        train.owner.remove_train(train)
        train.owner = self
        @discarded << train
      end

      def min_price
        [*@discarded, @upcoming.first].map(&:price).min
      end

      def remove_train(train)
        @upcoming.delete(train)
        @discarded.delete(train)
      end

      def available(corporation)
        [
          @upcoming.first,
          *@discarded,
          *@trains.reject { |t| [corporation, self, nil].include?(t.owner) }
        ]
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
