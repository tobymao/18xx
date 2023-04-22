# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1822
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            train = action.train

            if @game.remove_discarded_train?(train)
              @game.remove_train(train)
              @log << "#{action.entity.name} discards #{train.name}, #{train.name} is removed from the game"
            else
              train.remove_variants!
              @game.depot.reclaim_train(train)
              @log << "#{action.entity.name} discards #{train.name}"
            end
          end

          def trains(corporation)
            if @game.extra_train_permanent_count(corporation) > 1
              return corporation.trains.select { |t| @game.extra_train_permanent?(t) }
            end
            return corporation.trains.select { |t| @game.pullman_train?(t) } if @game.pullman_train_count(corporation) > 1

            corporation.trains.reject { |t| @game.extra_train?(t) }
          end
        end
      end
    end
  end
end
