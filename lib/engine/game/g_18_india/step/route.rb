# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18India
      module Step
        class Route < Engine::Step::Route
          # modified to claim commodities when routes are run
          def process_run_routes(action)
            super
            entity = action.entity
            @round.routes = action.routes
            @round.extra_revenue = action.extra_revenue
            trains = {}
            abilities = []

            @round.routes.each do |route|

              @log << "#{entity.name} used XXX commodities "
            end

          end

          def round_state
            super.merge(
              {
                commodities_used: [],
              }
            )
          end
        end
      end
    end
  end
end
