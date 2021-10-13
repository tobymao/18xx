# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G18TN
      class SharePool < Engine::SharePool
        def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil, allow_president_change: true)
          super

          return if shares.corporation.id != 'L&N' || !@game.lnr.owner

          @game.lnr.close!
          @log << "#{@game.lnr.name} private company closes as par set for #{shares.corporation.name}"
        end
      end
    end
  end
end
