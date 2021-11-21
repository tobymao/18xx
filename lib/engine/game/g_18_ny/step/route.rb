# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18NY
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super

            connection_bonus = false
            action.routes.flat_map(&:stops).select { |stop| stop.hex.assigned?('connection_bonus') }.each do |stop|
              @game.claim_connection_bonus(action.entity, stop.hex)
              connection_bonus = true
            end
            return unless connection_bonus

            # Recalculate revenue if a connection_bonus was claimed
            action.routes.each do |route|
              route.clear_cache!
              route.revenue
            end
          end
        end
      end
    end
  end
end
