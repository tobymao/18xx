# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18NY
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super
            return if (hexes = action.routes.flat_map { |route| @game.potential_route_connection_bonus_hexes(route) }.uniq).empty?

            hexes.each { |hex| @game.claim_connection_bonus(action.entity, hex) }
            action.routes.each { |route| route.clear_cache!(only_routes: true) }
          end
        end
      end
    end
  end
end
