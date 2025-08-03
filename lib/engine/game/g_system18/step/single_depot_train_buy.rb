# frozen_string_literal: true

require_relative 'buy_train'

module Engine
  module Game
    module GSystem18
      module Step
        class SingleDepotTrainBuy < Engine::Game::GSystem18::Step::BuyTrain
          def buyable_trains(entity)
            super.reject do |train|
              train.from_depot? && @round.bought_trains.include?(entity)
            end
          end

          def process_buy_train(action)
            from_depot = action.train.from_depot?
            super
            return unless from_depot

            entity = action.entity
            @round.bought_trains << entity
            pass! unless buyable_trains(entity).any?
          end

          def round_state
            { bought_trains: [] }
          end
        end
      end
    end
  end
end
