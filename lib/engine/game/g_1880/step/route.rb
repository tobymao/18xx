# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1880
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? ||
            (entity.runnable_trains.empty? && !entity.minor?) ||
            (@game.communism && entity.minor?) ||
            !@game.can_run_route?(entity)

            ACTIONS
          end
        end
      end
    end
  end
end
