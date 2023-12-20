# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1854
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super
            if !@round.routes.empty?
              # Close when a train is actually run, as opposed to just reaching the dividends step.
              # This event is not in the generic abilities, so create one that is the same as in the entities
              # and rely on the rest of the code to match them up.
              @game.close_companies_on_event!(action.entity, 'ran_train')
            end
          end
        end
      end
    end
  end
end
