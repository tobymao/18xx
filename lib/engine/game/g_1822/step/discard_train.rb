# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1822
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            entity = action.entity
            if current_entity != entity
              raise GameError, "Only #{entity.owner.name} can discard a train from #{entity.name}."
            end

            super
          end
        end
      end
    end
  end
end
