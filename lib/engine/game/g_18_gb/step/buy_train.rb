# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18GB
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership? && entity.trains.any?
            return [] if entity != current_entity

            actions = []
            actions << 'sell_shares' if entity.trains.empty? && can_convert?(entity)
            actions << 'buy_train' if can_buy_train?(entity)
            actions << 'pass' unless actions.empty? || must_buy_train?(entity)
            actions
          end

          def can_convert?(corporation)
            corporation&.type == '5-share'
          end

          def issuable_shares(entity)
            return [] unless entity.corporation?

            @game.emergency_convert_bundles(entity)
          end

          def process_sell_shares(action)
            return unless action.entity.corporation? && can_convert?(action.entity)

            @game.convert_to_ten_share(action.entity, 3)
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
