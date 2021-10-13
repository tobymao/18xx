# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1860
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def crowded_corps
            @game.entity_crowded_corps
          end

          def process_discard_train(action)
            super
            @game.update_crowded(action.entity)
          end
        end
      end
    end
  end
end
