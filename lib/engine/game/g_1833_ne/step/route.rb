# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1833NE
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super
            @game.flip_last_ferry_bonus!(action.entity)
          end

          def skip!
            @game.flip_last_ferry_bonus!(current_entity)
            super
          end
        end
      end
    end
  end
end
