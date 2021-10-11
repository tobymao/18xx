# frozen_string_literal: true

require_relative '../../g_1867/step/buy_train'

module Engine
  module Game
    module G1861
      module Step
        class BuyTrain < G1867::Step::BuyTrain
          include SkipForNational

          def buy_train(entity, train)
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

            buy_train(entity, @depot.min_depot_train) if must_buy_train?(entity)

            buy_train(entity, @depot.upcoming.first) while entity.cash > @depot.upcoming.first.price
          end

          def buyable_trains(entity)
            trains = super
            trains.reject { |t| t.owner.corporation? && t.owner.type == :national }
          end
        end
      end
    end
  end
end
