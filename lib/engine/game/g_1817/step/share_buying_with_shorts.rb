# frozen_string_literal: true

module Engine
  module Game
    module G1817
      module ShareBuyingWithShorts
        # Returns if a share can be gained by an entity respecting the cert limit
        # This works irrespective of if that player has sold this round
        # such as in 1889 for exchanging Dougo
        #
        def can_gain?(entity, bundle, exchange: false)
          return if !bundle || !entity
          return if bundle.owner&.player?

          corporation = bundle.corporation

          !(bundle.corporation.share_price.acquisition? || bundle.corporation.share_price.liquidation?) &&
          (@game.entity_shorts(entity, corporation).any? ||
          (corporation.holding_ok?(entity, bundle.percent) &&
            (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit)))
        end
      end
    end
  end
end
