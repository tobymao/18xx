# frozen_string_literal: true

require_relative '../../share_bundle'
require_relative '../../share_pool'

module Engine
  module Game
    module G18Chesapeake
      class SharePool < Engine::SharePool
        def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil,
                       allow_president_change: true, borrow_from: nil)
          return super unless shares
          return super unless @game.two_player?

          bundle = shares.to_bundle
          corporation = bundle.corporation

          share_to_remove = shares_by_corporation[corporation].last

          return super if !share_to_remove || (entity == corporation.owner) || (share_to_remove.owner != @game.share_pool)

          transfer_shares(share_to_remove.to_bundle, @game.bank)
          @log << "#{entity.name} removes a 10% share of #{corporation.name} from the game"

          return super unless bundle.shares.first == share_to_remove
        end
      end
    end
  end
end
