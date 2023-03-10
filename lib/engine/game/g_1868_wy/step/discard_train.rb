# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1868WY
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            super
            action.train.remove_variants!
          end
        end
      end
    end
  end
end
