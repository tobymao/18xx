# frozen_string_literal: true

require_relative '../../g_1858/step/token'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class Token < G1858::Step::Token
          def actions(entity)
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
