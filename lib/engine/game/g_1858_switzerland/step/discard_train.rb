# frozen_string_literal: true

require_relative '../../g_1858/step/discard_train'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class DiscardTrain < G1858::Step::DiscardTrain
          def crowded_corps
            return super unless @game.robot?

            super.reject { |entity| @game.robot_owner?(entity) }
          end
        end
      end
    end
  end
end
