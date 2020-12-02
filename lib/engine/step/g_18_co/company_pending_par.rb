# frozen_string_literal: true

require_relative '../company_pending_par.rb'

module Engine
  module Step
    module G18CO
      class CompanyPendingPar < CompanyPendingPar
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
