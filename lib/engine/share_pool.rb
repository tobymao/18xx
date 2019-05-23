# frozen_string_literal: true

require 'forwardable'

module Engine
  class SharePool
    extend Forwardable

    attr_reader :shares

    def_delegators :@bank, :add_cash, :remove_cash

    def initialize(corporations, bank)
      @corporations = corporations
      @bank = bank
      @shares = []
    end

    def buy_share(entity, share)
      transfer_share(entity, share)
    end

    def sell_share(share)
      transfer_share(self, share)
    end

    private

    def transfer_share(to_entity, share)
      price = share.corporation.share_price.price
      share.owner.shares.delete(share)
      share.owner.add_cash(price)
      to_entity.remove_cash(price)
      to_entity.shares << share
      share.owner = to_entity
    end
  end
end
