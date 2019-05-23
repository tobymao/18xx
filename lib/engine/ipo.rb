# frozen_string_literal: true

require 'engine/share_pool'

module Engine
  class Ipo < SharePool
    def buy_share(entity, share)
      transfer_share(entity, share)
    end

    def sell_share(share)
      transfer_share(@bank, share)
    end
  end
end
