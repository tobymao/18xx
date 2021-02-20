# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G1849
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end
        end
      end
    end
  end
end
