# frozen_string_literal: true

require_relative '../../g_1824/step/buy_sell_par_exchange_shares'

module Engine
  module Game
    module G1824Cisleithania
      module Step
        class BuySellParExchangeShares < G1824::Step::BuySellParExchangeShares
          def can_sell?(_entity, bundle)
            # Rule VI.8, bullet 1, sub-bullet 2: Bank ownership cannot exceed 50% for started corporations
            corp = bundle.corporation
            super && (@game.bond_railway?(corp) || (corp.ipo_shares.sum(&:percent) + bundle.percent <= 50))
          end

          # Rule X.4, bullet 2: Maybe exceed 60% in 2 player 1824, if buying from market
          def allowed_buy_from_market(_entity, bundle)
            return false unless @game.two_player?

            bundle.shares.first.owner == @game.share_pool
          end
        end
      end
    end
  end
end
