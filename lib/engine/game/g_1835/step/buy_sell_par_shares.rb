# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def process_buy_shares(action)
            if action.bundle.owner.player?
              raise GameError, 'Cannot nationalize this corporation' unless can_buy?(action.entity, action.bundle)

              action.bundle.share_price = nationalization_price(action.bundle.corporation.share_price.price)
            end
            owner = action.bundle.owner
            super
            @game.maybe_ipo_next_block(action.bundle.corporation) unless owner == @game.share_pool
          end

          def can_buy?(entity, bundle)
            if bundle&.owner&.player?
              return false unless can_nationalize?(entity, bundle.corporation)

              return entity.cash >= nationalization_price(bundle.price) &&
                !@round.players_sold[entity][bundle.corporation] &&
                can_gain?(entity, bundle)
            end

            return false unless super
            return true if bundle.owner == @game.share_pool

            # Enforce the block and company sequential availability rules for IPO shares
            return false unless @game.corporation_available?(bundle.corporation)

            # ensure 20% shares of BA, WT and HE cannot be bought before all 10% shares are gone
            return bundle.shares.first == bundle.corporation.shares.first unless bundle.corporation == @game.prussian

            # Ignore the order for PR: We cannot use the same logic we use for the other corporations, because the very first
            # share - the president - is reserved. If we used the same logic, no PR share could  ever be bought
            true
          end

          def allow_president_change?(corporation)
            # PR president can only change hands after it has been floated
            corporation.id != 'PR' || corporation.floated?
          end

          def can_sell?(entity, bundle)
            # Rule 7.4: Cannot sell shares in a company floated in the current share round
            # (it hasn't operated yet), except for the Prussian Railway.
            return false if bundle.corporation.id != 'PR' && !bundle.corporation.operated?

            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return false if bundle.owner.player? && !@game.can_gain_from_player?(entity, bundle)

            corporation = bundle.corporation

            corporation.holding_ok?(entity, bundle.common_percent) &&
              (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity))
          end

          def can_buy_any_from_player?(entity)
            return false if bought?

            @game.corporations.select(&:floated?).any? do |corporation|
              can_nationalize?(entity, corporation) && entity.cash >= nationalization_price(corporation.share_price.price)
            end
          end

          def nationalization_price(price)
            (price * 1.5).ceil
          end

          def can_nationalize?(player, corporation)
            return false unless player

            player.percent_of(corporation) > 50
          end
        end
      end
    end
  end
end
