# frozen_string_literal: true

require_relative 'action/buy_train.rb'

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

      train.owner.remove_train(train)
      train.owner = self
      @discarded << train if @game.class::DISCARDED_TRAINS == :discard && !train.obsolete
    end

    def min_price(corporation)
      available(corporation).map(&:min_price).min
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
    end

    def remove_train(train)
      @upcoming.delete(train)
      @discarded.delete(train)
    end

    def add_train(train)
      train.owner = self
      @trains << train
      @upcoming << train
    end

    def depot_trains
      [
        @upcoming.first,
        *@upcoming.select { |t| @game.phase.available?(t.available_on) },
      ].compact.uniq(&:name) + @discarded.uniq(&:name)
    end

    def discountable_trains_for(corporation)
      discountable_trains = depot_trains.select(&:discount)

      corporation.trains.flat_map do |train|
        discountable_trains.flat_map do |discount_train|
          discounted_price = discount_train.price(train)
          next if discount_train.price == discounted_price

          name = discount_train.name
          discount_info = [[train, discount_train, name, discounted_price]]

          # Add variants if any - they have same discount as base version
          discount_train.variants.each do |_, v|
            next if v[:name] == name

            price = v[:price] - (discount_train.price - discounted_price)
            discount_info << [train, discount_train, v[:name], price]
          end

          discount_info
        end.compact
      end
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
  end
end
