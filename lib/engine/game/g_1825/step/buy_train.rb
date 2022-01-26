# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1825
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if receivership_skip?(entity)
            return ['buy_train'] if entity.corporation? && entity.receivership?

            super
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains.reject { |t| entity.cash < t.price }
            other_trains = @depot.other_trains(entity)
            other_trains = [] if entity.cash < @game.class::TRAIN_PRICE_MIN || entity.receivership?

            depot_trains + other_trains
          end

          def spend_minmax(entity, _train)
            [@game.class::TRAIN_PRICE_MIN, buying_power(entity)]
          end

          def must_buy_train?(entity)
            entity.corporation? && entity.receivership?
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def skip!
            if current_entity.corporation? && current_entity.receivership? && !@game.silent_receivership?(current_entity)
              return receivership_buy(current_entity)
            end

            super
          end

          # auto-skip receivership companies if
          # - there is exactly zero or one train to buy, or
          # - there is no route to run, or
          # - there is no room for another train
          # - it's a minor and not Unit 3
          def receivership_skip?(entity)
            entity.corporation? && entity.receivership? &&
              (buyable_depot_trains(entity).size < 2 ||
               !@game.can_run_route?(entity) ||
               !room?(entity) ||
               @game.silent_receivership?(entity))
          end

          def buyable_depot_trains(entity)
            @depot.depot_trains.reject { |t| entity.cash < t.price }
          end

          def receivership_buy(entity)
            @passed = true
            trains = buyable_depot_trains(entity)

            if (train = trains.first) && @game.can_run_route?(entity) && room?(entity)
              raise GameError, 'multiple trains available for receivership purchase' if trains.size > 1

              @log << "#{entity.name} is in Receivership and must buy a #{train.name} train"

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
