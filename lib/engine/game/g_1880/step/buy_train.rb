# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1880
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def process_buy_train(action)
            train = action.train
            @game.train_marker = action.entity if train.owner == @game.depot
            super
            @round.bought_trains = true
          end

          def round_state
            { bought_trains: false }
          end

          def pass!
            return super unless discard_trains?

            discard_all_trains
          end

          def discard_trains?
            @game.train_marker && !@round.bought_trains
          end

          def discard_all_trains
            train_name = @game.depot.upcoming.first.name
            @game.log << "#{train_name} has not been bought for a full operating order, "\
                         "removing all remaining #{train_name} trains"
            @game.depot.export_all!(train_name, silent: true)
          end

          def setup
            super
            @round.bought_trains = false
          end
        end
      end
    end
  end
end
