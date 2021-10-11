# frozen_string_literal: true

require_relative '../../../step/company_pending_par'
module Engine
  module Game
    module G18Texas
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def round_state
            {
              companies_pending_par: [],
            }
          end
        end
      end
    end
  end
end
