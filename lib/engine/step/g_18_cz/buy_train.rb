# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18CZ
      class BuyTrain < BuyTrain
        def buyable_trains(entity)
          trains = super
          trains.select { |item| item.owner == @game.depot || train_available?(entity, item) }
        end

        def buyable_train_variants(train, entity)
          trains = super

          return [] if trains.empty?

          default_trains = trains.select { |item| @game.train_of_size?(item, :small) }
          return default_trains if entity.type == :small

          medium_trains = trains.select { |item| @game.train_of_size?(item, :medium) }
          if entity.type == :medium
            return medium_trains if entity.trains.none? do |item|
              @game.train_of_size?(item, :medium)
            end && room_for_only_one?(entity)

            return default_trains.concat(medium_trains)
          end

          large_trains = trains.select { |item| @game.train_of_size?(item, :large) }

          large_trains if entity.trains.none? do |item|
            @game.train_of_size?(item, :large)
          end && room_for_only_one?(entity)
          default_trains.concat(medium_trains).concat(large_trains)
        end

        def room_for_only_one?(entity)
          @game.train_limit(entity) - entity.trains.size == 1
        end

        def can_sell?(_entity, _bundle)
          false
        end

        def try_take_player_loan(entity, cost)
          return unless cost.positive?
          return unless cost > entity.cash

          difference = cost - entity.cash

          @game.increase_debt(entity, difference)

          @log << "#{entity.name} takes a debt of #{@game.format_currency(difference)}"

          @game.bank.spend(difference, entity)
        end

        def train_available?(entity, train)
          return true if @game.train_of_size?(train, entity.type) || @game.train_of_size?(train, :small)
          return false if entity.type == :small

          return true if @game.train_of_size?(train, :medium)

          false
        end
      end
    end
  end
end
