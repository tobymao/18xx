# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1822
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            train = action.train

            if @game.extra_train_permanent?(train)
              @game.remove_train(train)
              @log << "#{action.entity.name} discards #{train.name}, #{train.name} is removed from the game"
            else
              # Remove any variants on the train before reclaiming it
              train.variants.select! { |v| v == train.name }
              @game.depot.reclaim_train(train)
              @log << "#{action.entity.name} discards #{train.name}"
            end
          end

          def trains(corporation)
            if @game.extra_train_permanent_count(corporation) > 1
              return corporation.trains.select { |t| @game.extra_train_permanent?(t) }
            end

            corporation.trains.reject { |t| @game.extra_train?(t) }
          end
        end
      end
    end
  end
end
