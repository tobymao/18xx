# frozen_string_literal: true

require_relative '../../g_1822/step/minor_acquisition'

module Engine
  module Game
    module G1822PNW
      module Step
        class MinorAcquisition < Engine::Game::G1822::Step::MinorAcquisition
          include Engine::Game::G1822PNW::Connections

          def potentially_mergeable(entity)
            super + @game.regionals.select { |r| @game.regional_payout_count(r) > 1 }
          end
        end
      end
    end
  end
end
