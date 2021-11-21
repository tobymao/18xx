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
            action.routes.each(&:clear_cache!) if connection_bonus
          end
        end
      end
    end
  end
end
