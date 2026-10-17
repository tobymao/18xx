# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1864
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def trains(corporation)
            super.reject { |train| @game.pullman?(train) }
          end

          def process_discard_train(action)
            raise GameError, 'The Pullman cannot be discarded' if @game.pullman?(action.train)

            super
          end
        end
      end
    end
  end
end
