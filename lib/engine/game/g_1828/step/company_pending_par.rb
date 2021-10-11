# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G1828
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def get_par_prices(_entity, _corp)
            @game.par_prices
          end
        end
      end
    end
  end
end
