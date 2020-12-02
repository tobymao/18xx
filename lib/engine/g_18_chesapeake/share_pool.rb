# frozen_string_literal: true

require_relative '../share_bundle'
require_relative '../share_pool'

module Engine
  module G18Chesapeake
    class SharePool < SharePool
      def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil)
        return super unless shares
        return super unless @game.two_player?

        bundle = shares.to_bundle
        corporation = bundle.corporation

        return super if (entity == corporation.owner) || !corporation.floated?

        removed_share = shares_by_corporation[corporation].last
        transfer_shares(removed_share.to_bundle, @game.bank)
        @log << "#{entity.name} removes a 10% share of #{corporation.name} from the game"

        return super unless bundle.shares.first == removed_share
      end
    end
  end
end
