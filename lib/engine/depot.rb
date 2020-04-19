# frozen_string_literal: true

module Engine
  class Depot
    attr_reader :trains, :upcoming, :discarded

    def initialize(trains, game)
      @game = game
      @trains = trains
      @trains.each { |train| train.owner = self }
      @upcoming = @trains.dup
      @discarded = []
      @bank = @game.bank
    end

    def reclaim_train(train)
      return unless train.owner

      train.owner.remove_train(train)
      train.owner = self

      if (index = @upcoming.find_index { |t| t.name == train.name })
        @upcoming.insert(index, train)
      else
        @discarded << train
      end
    end

    def min_price(corporation)
      available(corporation).map(&:price).min
    end

    def remove_train(train)
      @upcoming.delete(train)
      @discarded.delete(train)
    end

    def new_trains
      [
        @upcoming.first,
        *@upcoming.select { |t| @game.phase.available?(t.available_on) },
      ].uniq(&:name)
    end

    def available(corporation)
      depot_trains = (new_trains + @discarded).uniq(&:name)
      other_trains = @trains.reject { |t| [corporation, self, nil].include?(t.owner) }
      depot_trains + other_trains
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
