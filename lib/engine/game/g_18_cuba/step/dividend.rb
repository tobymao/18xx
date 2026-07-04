# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Cuba
      module Step
        class Dividend < Engine::Step::Dividend
          def process_dividend(action)
            entity = action.entity
            revenue = total_revenue
            # Capture the routes before super, which resets @round.routes.
            routes = @round.routes
            super

            @game.sugar_production(entity, revenue)
            @game.collect_wagon_cubes(routes)
            # Drop any loaded-but-undelivered cubes so no binding leaks past the turn (mirrors 18Uruguay).
            entity.trains.each { |train| @game.unload_cubes(train) }
          end
        end
      end
    end
  end
end
