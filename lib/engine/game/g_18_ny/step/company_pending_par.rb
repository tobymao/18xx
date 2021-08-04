# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G18NY
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def get_par_prices(_entity, _corp)
            @game.stock_market.share_prices_with_types(%i[par])
          end
        end
      end
    end
  end
end
