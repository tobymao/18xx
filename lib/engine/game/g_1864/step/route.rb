# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1864
      module Step
        class Route < Engine::Step::Route
          # Pullman Car grants its bonus to only one train per route-running
          # action ("one train of this company"). `Game#compute_stops` is
          # memoized per `Engine::Route` instance and those instances are
          # rebuilt fresh from the submitted action, so resetting the flag
          # here - immediately before the routes are actually run - is
          # sufficient to make the grant deterministic without leaking across
          # corporations or OR turns.
          def process_run_routes(action)
            @game.reset_pullman_bonus!
            super
          end
        end
      end
    end
  end
end
