# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1833NE
      module Step
        class Route < Engine::Step::Route
          def available_hex(entity, hex)
            @game.extension_graph.reachable_hexes(entity)[hex]
          end

          def process_run_routes(action)
            super
            @game.flip_last_ferry_bonus!(action.entity)
          end

          # Called when the corporation has no routes to run, so the flip still happens.
          def skip!
            @game.flip_last_ferry_bonus!(current_entity) if current_entity
            super
          end
        end
      end
    end
  end
end
