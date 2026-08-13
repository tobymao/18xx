# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1864
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            @game.reset_pullman_bonus!
            super
          end
        end
      end
    end
  end
end
