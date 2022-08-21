# frozen_string_literal: true

require_relative '../../g_1822/step/route'

module Engine
  module Game
    module G1822PNW
      module Step
        class Route < Engine::Game::G1822::Step::Route
          def available_hex(entity, hex)
            super || (@game.owns_coal_company?(entity) && super(@game.hidden_coal_corp, hex))
          end
        end
      end
    end
  end
end
