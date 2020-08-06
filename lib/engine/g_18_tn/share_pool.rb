# frozen_string_literal: true

require_relative '../share_pool'

module Engine
  module G18TN
    class SharePool < SharePool
      def buy_shares(entity, shares, exchange: nil, exchange_price: nil)
        super

        return if @game.turn != 1

        lnr = @game.company_by_id('LNR')
        return if !lnr || !lnr.owner

        lnr.close!
        @log << "#{lnr.name} private company closes as par set"
      end
    end
  end
end
