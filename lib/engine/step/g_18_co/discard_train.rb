# frozen_string_literal: true

require_relative '../discard_train'

module Engine
  module Step
    module G18CO
      class DiscardTrain < DiscardTrain
        def process_discard_train(action)
          train = action.train
          return super unless train.name == '2P'

          @game.remove_train(train)
          @log << "#{action.entity.name} discards #{train.name} and it is removed from the game"
        end
      end
    end
  end
end
