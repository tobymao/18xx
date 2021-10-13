# frozen_string_literal: true

require_relative 'action/buy_train'
require_relative 'entity'

module Engine
  class Depot
    include Entity

    attr_reader :trains, :upcoming, :discarded

    def initialize(trains, game)
      @game = game
      @trains = trains
      @trains.each { |train| train.owner = self }
      @upcoming = @trains.dup
      @discarded = []
      @bank = @game.bank
    end

    def export!
      train = @upcoming.first
      @game.log << "-- Event: A #{train.name} train exports --"
      remove_train(train)
      @game.phase.buying_train!(nil, train)
    end

    def export_all!(name)
      @game.log << "-- Event: All #{name} trains are exported --"
      while (train = @upcoming.first).name == name
        remove_train(train)
        @game.phase.buying_train!(nil, train)
      end
    end

    def reclaim_train(train)
      return unless train.owner

      @game.remove_train(train)
      train.owner = self
      @discarded << train if @game.class::DISCARDED_TRAINS == :discard && !train.obsolete
      @depot_trains = nil
    end

    # if set, ability must be a :train_discount ability
    def min_price(corporation, ability: nil)
      available(corporation).map { |train| train.min_price(ability: ability) }.min
    end

    def min_depot_train
      depot_trains.min_by(&:price)
    end

    def min_depot_price
      return 0 unless (train = min_depot_train)

      train.variants.map { |_, v| v[:price] }.min
    end

    def max_depot_price
      return 0 unless (train = depot_trains.max_by(&:price))

      train.variants.map { |_, v| v[:price] }.max
    end

    def unshift_train(train)
      train.owner = self
      @upcoming.unshift(train)
      @depot_trains = nil
    end

    def remove_train(train)
      @upcoming.delete(train)
      @discarded.delete(train)
      @depot_trains = nil
    end

    def forget_train(train)
      @trains.delete(train)
      @upcoming.delete(train)
      @discarded.delete(train)
      @depot_trains = nil
    end

    def add_train(train)
      train.owner = self
      @trains << train
      @upcoming << train
      @depot_trains = nil
    end

    def depot_trains(clear: false)
      @depot_trains = nil if clear
      @depot_trains ||= [
        @upcoming.first,
        *@upcoming.select { |t| @game.phase.available?(t.available_on) },
      ].compact.uniq(&:name) + @discarded.uniq(&:name)
    end

    def available(corporation)
      depot_trains + other_trains(corporation)
    end

    def other_trains(corporation)
      @trains.reject do |train|
        !train.buyable || [corporation, self, nil].include?(train.owner)
      end
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

    def empty?
      depot_trains.empty?
    end

    def player
      nil
    end
  end
end
