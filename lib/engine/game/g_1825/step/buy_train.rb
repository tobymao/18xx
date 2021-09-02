# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1825
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            other_trains = @depot.other_trains(entity)

            depot_trains.reject! { |t| entity.cash < t.price }
            other_trains = [] if entity.cash < @game.class::TRAIN_PRICE_MIN || entity.receivership?

            depot_trains + other_trains
          end

          def spend_minmax(entity, _train)
            [@game.class::TRAIN_PRICE_MIN, buying_power(entity)]
          end

          def must_buy_train?(_entity)
            false
          end
        end
      end
    end
  end
end
