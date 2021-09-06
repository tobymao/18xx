# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1825
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.corporation? && entity.receivership?

            super
          end

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

          def skip!
            if current_entity.corporation? && current_entity.receivership? && !@game.silent_receivership?(current_entity)
              return receivership_buy(current_entity)
            end

            super
          end

          def receivership_buy(entity)
            @passed = true
            train = @depot.depot_trains.first
            if entity.cash >= train.price && @game.can_run_route?(entity) && room?(entity)
              @log << "#{entity.name} is in Receivership and must buy a train"

              buy_train_action(
                Engine::Action::BuyTrain.new(
                  entity,
                  train: train,
                  price: train.price
                )
              )
            else
              log_skip(entity)
            end
          end
        end
      end
    end
  end
end
