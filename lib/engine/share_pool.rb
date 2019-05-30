# frozen_string_literal: true

require 'engine/corporation/base'

module Engine
  class SharePool
    attr_reader :corporations, :shares

    def initialize(corporations, bank)
      @corporations = corporations
      @bank = bank
      @shares = []
    end

    def remove_cash(cash)
      @bank.remove_cash(cash)
    end

    def add_cash(cash)
      @bank.add_cash(cash)
    end

    def buy_share(entity, share)
      share.corporation.ipoed = true
      transfer_share(entity, share)
    end

    def sell_share(share)
      transfer_share(self, share)
    end

    private

    def transfer_share(to_entity, share)
      price = share.corporation.share_price.price
      owner = share.owner
      owner.shares.delete(share)
      owner.is_a?(Corporation::Base) ? add_cash(price) : owner.add_cash(price)
      to_entity.remove_cash(price)
      to_entity.shares << share
      share.owner = to_entity
    end
  end
end
