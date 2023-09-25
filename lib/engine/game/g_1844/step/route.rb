# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1844
      module Step
        class Route < Engine::Step::Route
          def help
            'Corporations must run for highest total revenue. It is illegal to run for less revenue' \
              ' in order to activate a Mountain Railway or Tunnel Company.'
          end

          def process_run_routes(action)
            super
            @game.check_for_mountain_or_tunnel_activation(action.routes)
          end
        end
      end
    end
  end
end
