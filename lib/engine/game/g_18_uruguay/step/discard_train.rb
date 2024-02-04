# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G18Uruguay
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            action.train.remove_variants!
            super
          end
        end
      end
    end
  end
end
