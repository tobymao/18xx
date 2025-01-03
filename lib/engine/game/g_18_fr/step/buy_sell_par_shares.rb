# frozen_string_literal: true

require_relative '../../g_1817/step/buy_sell_par_shares'

module Engine
  module Game
    module G18FR
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          MIN_BID = 90
        end
      end
    end
  end
end
