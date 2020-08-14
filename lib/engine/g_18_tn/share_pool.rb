# frozen_string_literal: true

require_relative '../share_pool'

module Engine
  module G18TN
    class SharePool < SharePool
      def buy_shares(entity, shares, exchange: nil, exchange_price: nil)
        super

        return if shares.corporation.id != 'L&N' || !@game.lnr.owner

        @game.lnr.close!
        @log << "#{@game.lnr.name} private company closes as par set for #{shares.corporation.name}"
      end
    end
  end
end
