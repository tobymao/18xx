# frozen_string_literal: true

require_relative '../../g_1822/step/choose'

module Engine
  module Game
    module G1822PNW
      module Step
        class Choose < Engine::Game::G1822::Step::Choose
          def find_company(entity)
            @company = @game.company_by_id('P7')
            return nil if !@company || @company&.owner != entity

            @company
          end
        end
      end
    end
  end
end
