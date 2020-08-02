# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module ShareBuying
      def buy_shares(entity, shares, exchange: nil)
        @game.game_error("Cannot buy a share of #{shares&.corporation&.name}") unless can_buy?(entity, shares)

        @game.share_pool.buy_shares(entity, shares, exchange: exchange)
        corporation = shares.corporation
        @game.place_home_token(corporation) if @game.class::HOME_TOKEN_TIMING == :float && corporation.floated?
      end

      # Returns if a share can be gained by an entity respecting the cert limit
      # This works irrespective of if that player has sold this round
      # such as in 1889 for exchanging Dougo
      #
      def can_gain?(entity, bundle)
        return if !bundle || !entity

        corporation = bundle.corporation
        corporation.holding_ok?(entity, bundle.percent) &&
          (!corporation.counts_for_limit || entity.num_certs < @game.cert_limit)
      end
    end
  end
end
