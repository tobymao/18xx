# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G18Scan
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def process_par(action)
            corporation = action.corporation

            super

            # Place home token when DSB floats on SJS private buy in ISR
            @game.place_home_token(corporation) if corporation.floated?
          end
        end
      end
    end
  end
end
