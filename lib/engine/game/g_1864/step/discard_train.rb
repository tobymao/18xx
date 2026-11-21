# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1864
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            raise GameError, 'The Pullman cannot be discarded' if @game.extra_train?(action.train)

            super
          end
        end
      end
    end
  end
end
