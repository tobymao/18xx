# frozen_string_literal: true

require_relative '../../share_pool'
require_relative 'corporation'
# require_relative 'entity'
# require_relative 'share_bundle'
# require_relative 'share_holder'

module Engine
  module Game
    module G18India
      class IpoPool < Engine::SharePool

        def name
          'IPO Pool'
        end

        def add_ipo_share(share)
          corporation = share.corporation
          owner = share.owner
          corporation.share_holders[owner] -= share.percent
          corporation.share_holders[self] += share.percent
          share.owner.shares_by_corporation[corporation].delete(share)
          self.shares_by_corporation[corporation] << share
          share.owner = self
        end


      end
    end
  end
end