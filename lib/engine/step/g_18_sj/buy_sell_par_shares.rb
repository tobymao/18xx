# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18SJ
      class BuySellParShares < BuySellParShares
        def can_sell?(entity, bundle)
          super && bundle.corporation.floated?
        end
      end
    end
  end
end
