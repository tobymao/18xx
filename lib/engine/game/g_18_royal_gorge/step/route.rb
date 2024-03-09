# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class Route < Engine::Step::Route
          def round_state
            super.merge(
              {
                hanging_bridge_lease_payment: 0,
              }
            )
          end

          def available_hex(entity, hex)
            return true if entity == @game.hanging_bridge_lease&.owner

            @game.graph_for_entity(entity).reachable_hexes(entity)[hex]
          end

          def process_run_routes(action)
            super

            return unless action.entity == @game.hanging_bridge_lease&.owner
            return if action.entity == @game.rio_grande
            return unless (route = action.routes.find { |r| r.hexes.any? { |h| h.id == @game.class::ROYAL_GORGE_TOWN_HEX } })

            @round.hanging_bridge_lease_payment = route.revenue / 10
          end
        end
      end
    end
  end
end
