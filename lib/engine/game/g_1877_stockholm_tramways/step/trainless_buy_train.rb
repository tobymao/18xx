# frozen_string_literal: true

require_relative 'buy_train'

module Engine
  module Game
    module G1877StockholmTramways
      module Step
        class TrainlessBuyTrain < G1877StockholmTramways::Step::BuyTrain
          def actions(entity)
            return [] unless entity.trains.empty?
            return [] if entity != current_entity || buyable_trains(entity).empty?
            return %w[buy_train] if must_buy_train?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end
        end
      end
    end
  end
end
