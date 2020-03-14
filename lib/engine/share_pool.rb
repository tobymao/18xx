# frozen_string_literal: true

require 'engine/corporation/base'
require 'engine/share_holder'

module Engine
  class SharePool
    include ShareHolder
    attr_reader :corporations

    def initialize(corporations, bank)
      @corporations = corporations
      @bank = bank
    end

    def buy_share(entity, share)
      share.corporation.ipoed = true
      transfer_share(share, entity, entity, @bank)
    end

    def sell_share(share)
      transfer_share(share, self, @bank, share.owner)
    end
  end
end
