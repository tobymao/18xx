# frozen_string_literal: true

require_relative '../../g_1822/step/minor_acquisition'

module Engine
  module Game
    module G1822PNW
      module Step
        class MinorAcquisition < Engine::Game::G1822::Step::MinorAcquisition
          def potentially_mergeable(entity)
            super + @game.regionals
          end
        end
      end
    end
  end
end
