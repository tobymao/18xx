# frozen_string_literal: true

require_relative '../../g_1822/step/route'

module Engine
  module Game
    module G1822MX
      module Step
        class Route < Engine::Game::G1822::Step::Route
          def help
            return super unless current_entity.id == 'NDEM'

            'NDEM has no president.  The shareholder in highest priority will run the '\
              'trains.  If there are no shareholders, the player with priority will do so.'
          end
        end
      end
    end
  end
end
