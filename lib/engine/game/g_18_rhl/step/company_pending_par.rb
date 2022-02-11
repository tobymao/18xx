# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G18Rhl
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def get_par_prices(_entity, corp)
            par_prices = super
            return par_prices unless corp == @game.rhe

            par_prices.select { |p| p.price >= 70 && p.price <= 80 }
          end
        end
      end
    end
  end
end
