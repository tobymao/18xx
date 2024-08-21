# frozen_string_literal: true

require_relative '../../g_1858/step/discard_train'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class DiscardTrain < G1858::Step::DiscardTrain
          def actions(entity)
            return [] unless entity == current_entity
            return [] if @game.robot_owner?(entity)

            super
          end

          def skip!
            super unless @game.robot_owner?(current_entity)
          end
        end
      end
    end
  end
end
