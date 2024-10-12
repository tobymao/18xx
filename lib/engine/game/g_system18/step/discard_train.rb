# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module GSystem18
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            train = action.train

            return super unless @game.remove_discarded_train?(train)

            @game.remove_train(train)
            @log << "#{action.entity.name} discards #{train.name}, #{train.name} is removed from the game"
          end
        end
      end
    end
  end
end
