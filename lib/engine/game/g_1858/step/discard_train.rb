# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1858
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            super
            @game.depot.forget_train(action.train) if action.train.obsolete
          end
        end
      end
    end
  end
end
