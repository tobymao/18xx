# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G1880
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def process_par(action)
            super
            corporation = action.corporation
            @log << "#{corporation.name} selects ABC building permit"
            corporation.building_permits = 'ABC'
          end

          def auto_actions(entity)
            share = @game.abilities(companies_pending_par.first, :shares).shares.first
            share_price = @game.stock_market.par_prices.find { |pp| pp.price == 100 }
            [Engine::Action::Par.new(entity, corporation: share.corporation, share_price: share_price)]
          end
        end
      end
    end
  end
end
