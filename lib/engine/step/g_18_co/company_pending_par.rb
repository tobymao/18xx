# frozen_string_literal: true

require_relative '../company_pending_par.rb'

module Engine
  module Step
    module G18CO
      class CompanyPendingPar < CompanyPendingPar
        def get_par_prices(_entity, _corp)
          # TODO: Par groups
          super
        end
      end
    end
  end
end
