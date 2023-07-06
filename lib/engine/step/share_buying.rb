# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module ShareBuying
      def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil,
                     allow_president_change: true, borrow_from: nil, silent: nil)
        check_legal_buy(entity,
                        shares,
                        exchange: exchange,
                        swap: swap,
                        allow_president_change: allow_president_change)

        @game.share_pool.buy_shares(entity,
                                    shares,
                                    exchange: exchange,
                                    exchange_price: exchange_price,
                                    swap: swap,
                                    borrow_from: borrow_from,
                                    allow_president_change: allow_president_change,
                                    silent: silent)

        maybe_place_home_token(shares.corporation)
      end

      def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
        raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if
            !can_buy?(entity, shares.to_bundle) && !swap
      end

      def maybe_place_home_token(corporation)
        if (@game.class::HOME_TOKEN_TIMING == :float && corporation.floated?) ||
            (@game.class::HOME_TOKEN_TIMING == :par && corporation.ipoed)
          @game.place_home_token(corporation)
        end
      end

      def can_gain?(entity, bundle, exchange: false)
        return if !bundle || !entity
        return false if bundle.owner.player? &&
                        !@game.class::BUY_SHARE_FROM_OTHER_PLAYER &&
                        (!@game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT || !entity.corporation?)

        corporation = bundle.corporation

        corporation.holding_ok?(entity, bundle.common_percent) &&
          (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity))
      end

      def swap_buy(_player, _corporation, _ipo_or_pool_share); end

      def swap_sell(_player, _corporation, _bundle, _pool_share); end
    end
  end
end
