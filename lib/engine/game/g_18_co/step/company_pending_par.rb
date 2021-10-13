# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G18CO
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def get_par_prices(_entity, corp)
            @game.par_prices(corp)
          end

          def process_par(action)
            super(action)

            @game.par_change_float_percent(action.corporation)
          end
        end
      end
    end
  end
end
