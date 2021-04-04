# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G1870
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def process_par(action)
            company = @round.companies_pending_par.first

            super

            company.close!
          end
        end
      end
    end
  end
end
