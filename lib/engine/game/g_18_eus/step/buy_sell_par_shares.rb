# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'bidbox_auction'

module Engine
  module Game
    module G18EUS
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include BidboxAuction

        end
      end
    end
  end
end
