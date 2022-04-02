# frozen_string_literal: true

require_relative '../../g_1822/step/token'

module Engine
  module Game
    module G1822MX
      module Step
        class Token < Engine::Game::G1822::Step::Token
          def can_place_token?(entity)
            return false if entity.id == 'NDEM'

            super
          end
        end
      end
    end
  end
end
