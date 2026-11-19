# frozen_string_literal: true

require_relative '../../g_1861/step/buy_sell_par_shares'

module Engine
  module Game
    module G1864
      module Step
        class BuySellParShares < G1861::Step::BuySellParShares
          def win_bid(winner, company)
            super
            @game.activate_minor_power!(winner.corporation)
          end
        end
      end
    end
  end
end
