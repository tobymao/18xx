# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G18NY
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            @game.salvage_train(action.train)
          end
        end
      end
    end
  end
end
