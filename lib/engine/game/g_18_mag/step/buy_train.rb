# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Mag
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity != current_entity || entity.corporation? || buyable_trains(entity).empty?
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def log_skip(entity)
            super unless entity.corporation?
          end

          def buyable_trains(entity)
            # All trains start out available
            depot_trains = @depot.upcoming.group_by(&:name).map { |_k, v| v.first }
            other_trains = @depot.other_trains(entity)

            depot_trains.reject! { |t| entity.cash < t.price }
            other_trains = [] if entity.cash < @game.class::TRAIN_PRICE_MIN

            depot_trains + other_trains
          end
        end
      end
    end
  end
end
