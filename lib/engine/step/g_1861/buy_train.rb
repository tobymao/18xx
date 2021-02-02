# frozen_string_literal: true

require_relative '../g_1867/buy_train'

module Engine
  module Step
    module G1861
      class BuyTrain < G1867::BuyTrain
        include SkipForNational

        def buy_cheapest(entity)
          train = @depot.min_depot_train
          action = Engine::Action::BuyTrain.new(
            entity,
            train: train,
            price: train.price,
          )
          process_buy_train(action)
        end

        def skip!
          entity = current_entity
          return super if entity.type != :national

          buy_cheapest(entity) while must_buy_train?(entity) || entity.cash > @depot.min_depot_train.price
        end

        def buyable_trains(entity)
          trains = super
          trains.reject { |t| t.owner.corporation? && t.owner.type == :national }
        end
      end
    end
  end
end
