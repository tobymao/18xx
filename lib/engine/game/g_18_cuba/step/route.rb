# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Cuba
      module Step
        class Route < Engine::Step::Route
          def round_state
            # TODO: wagon_for_train is populated in the follow-up PR (wagon harbor route logic).
            # Currently always empty; check_distance and check_route_combination fall back to super.
            super.merge({ wagon_for_train: {} })
          end
        end
      end
    end
  end
end
