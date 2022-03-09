# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'swap_buy_sell'

module Engine
  module Game
    module G18MEX
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_buy?(entity, bundle)
            return false if attempt_ndm_action_on_unavailable?(bundle)

            super
          end

          def can_sell?(entity, bundle)
            return false if attempt_ndm_action_on_unavailable?(bundle)

            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if attempt_ndm_action_on_unavailable?(bundle)
            return if !bundle || !entity

            corporation = bundle.corporation

            corporation.holding_ok?(entity, bundle.percent) && (exchange || room_to_gain?(entity, bundle, exchange))
          end

          include SwapBuySell

          def can_buy_any?(entity)
            return true if super

            # If all we can do is swap, ensure we're given the opportunity for it
            ndm = @game.ndm
            valid_pool_shares = @game.share_pool.shares_by_corporation[ndm].select { |s| s.percent == 10 }
            return true if !valid_pool_shares.empty? && swap_buy(entity, ndm, valid_pool_shares[0])
          end

          private

          def attempt_ndm_action_on_unavailable?(bundle)
            bundle.corporation == @game.ndm && @game.phase.status.include?('ndm_unavailable')
          end

          # Need to allow buying 5% shares in NdM even if at cert limit as these shares are not
          # counted towards cert limit (but they still count for 60% corporation limit).
          def room_to_gain?(entity, bundle, exchange)
            return true if bundle.corporation == @game.ndm &&
                           @game.num_certs(entity) == @game.cert_limit &&
                           bundle.percent == 5 &&
                           !exchange

            @game.num_certs(entity) < @game.cert_limit
          end
        end
      end
    end
  end
end
