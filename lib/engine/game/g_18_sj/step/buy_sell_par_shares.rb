# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18SJ
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_sell?(entity, bundle)
            super && bundle.corporation.floated?
          end
        end
      end
    end
  end
end
