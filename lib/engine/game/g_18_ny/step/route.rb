# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18NY
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super
            action.routes.map(&:stops).flatten.select { |stop| stop.hex.assigned?('connection_bonus') }.each do |stop|
              stop.hex.remove_assignment!('connection_bonus')
              @game.claim_connection_bonus(action.entity)
            end
          end
        end
      end
    end
  end
end
