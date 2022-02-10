# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18GB
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership? && entity.trains.any?
            return [] if entity != current_entity || buyable_trains(entity).empty?
            return %w[buy_train] if must_buy_train?(entity)

            super
          end

          def president_may_contribute?
            false
          end

          def spend_minmax(_entity, train)
            [1, train.price * 2]
          end

          def illegal_train_buy?(entity, train)
            entity.receivership? || train.owner.receivership? || (!entity.trains.empty? && train.owner.trains.size < 2)
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            depot_trains = [] if entity.cash < @depot.min_depot_price

            other_trains = @depot.other_trains(entity)
            other_trains = [] if entity.cash.zero?
            other_trains.reject! { |t| illegal_train_buy?(entity, t) }

            depot_trains + other_trains
          end

          def must_buy_train?(entity)
            cheapest = @game.depot.min_depot_price
            entity.trains.empty? && cheapest.positive? && entity.cash > cheapest
          end
        end
      end
    end
  end
end
