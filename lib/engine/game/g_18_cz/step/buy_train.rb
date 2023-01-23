# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18CZ
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            trains = super
            trains.select do |item|
              item.owner == @game.depot ||
              (train_available?(entity, item) && !@game.corporation_of_vaclav?(item.owner))
            end
          end

          def buyable_train_variants(train, entity)
            trains = super

            return [] if trains.empty?

            trains = trains.reject { |item| @game.variant_is_rusted?(item) }

            default_trains = trains.select do |item|
              @game.train_of_size?(item, :small) && (entity.type == :small || can_afford?(entity, item, train))
            end
            return default_trains if entity.type == :small

            medium_trains = trains.select do |item|
              @game.train_of_size?(item, :medium) && (entity.type == :medium || can_afford?(entity, item, train))
            end
            if entity.type == :medium
              return medium_trains if entity.trains.none? do |item|
                @game.train_of_size?(item, :medium)
              end && room_for_only_one?(entity)

              return default_trains.concat(medium_trains)
            end

            large_trains = trains.select { |item| @game.train_of_size?(item, :large) }

            return large_trains if entity.trains.none? do |item|
              @game.train_of_size?(item, :large)
            end && room_for_only_one?(entity)

            default_trains.concat(medium_trains).concat(large_trains)
          end

          def can_afford?(entity, variant, train)
            entity.cash >= variant[:price] || train.owner != @game.depot
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

          def check_for_cheapest_train(train); end

          def cheapest_train_price(corporation)
            cheapest_train = @depot.min_depot_train.variants.values.find do |item|
              @game.train_of_size?(item, corporation.type)
            end

            # if the discard contains a train without the variant (e.g. 2a)
            cheapest_train ||= @depot.upcoming.uniq(&:name).min_by(&:price).variants.values.find do |item|
              @game.train_of_size?(item, corporation.type)
            end

            cheapest_train[:price]
          end

          def must_take_player_loan?(corporation)
            price = cheapest_train_price(corporation)
            (@game.buying_power(corporation) + corporation.owner.cash) < price
          end
        end
      end
    end
  end
end
