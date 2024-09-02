# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G18ESP
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def get_par_prices(_entity, _corp)
            super.reject do |p|
              p.price == 100 || p.price == 95 unless @game.phase.status.include?('higher_par_prices')
            end
          end
        end
      end
    end
  end
end
