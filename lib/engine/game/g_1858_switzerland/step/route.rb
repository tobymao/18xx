# frozen_string_literal: true

require_relative '../../g_1858/step/route'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class Route < G1858::Step::Route
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
