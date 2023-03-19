# frozen_string_literal: true

require_relative '../../g_1822/step/discard_train'

module Engine
  module Game
    module G1822MX
      module Step
        class DiscardTrain < Engine::Game::G1822::Step::DiscardTrain
          def trains(corporation)
            if @game.extra_train_pullman_count(corporation) > 1
              corporation.trains.select { |t| @game.extra_train_pullman?(t) } + super
            else
              super
            end
          end

          def process_discard_train(action)
            if action.entity == @game.ndem || @game.extra_train_pullman?(action.train)
              @game.remove_train(action.train)
              @log << "#{action.entity.name} discards #{action.train.name}, #{action.train.name} is removed from the game"
            else
              super
            end
          end
        end
      end
    end
  end
end
