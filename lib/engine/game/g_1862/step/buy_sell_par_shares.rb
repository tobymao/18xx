# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          UNCHARTERED_TOKEN_COST = 40

          def can_buy?(entity, bundle)
            return unless bundle&.buyable

            corporation = bundle.corporation
            entity.cash >= bundle.price && can_gain?(entity, bundle) &&
              !@round.players_sold[entity][corporation] &&
              (can_buy_multiple?(entity, corporation, bundle.owner) || !bought?) &&
              can_buy_presidents_share?(entity, bundle, corporation)
          end

          # can never directly buy president's share from market
          def can_buy_presidents_share?(_entity, share, corporation)
            share.percent < corporation.presidents_percent || share.owner != @game.share_pool
          end

          def can_buy_any?(entity)
            (can_buy_any_from_market?(entity) ||
             can_buy_any_from_ipo?(entity) ||
             can_buy_any_from_treasury?(entity))
          end

          def can_buy_any_from_treasury?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if can_buy_shares?(entity, corporation.shares)
            end

            false
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if can_buy_shares?(entity, corporation.ipo_shares)
            end

            false
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.ipo_shares.first&.to_bundle)
            end
          end

          # can't sell partial president's share to pool if pool doesn't have enough
          def can_dump?(entity, bundle)
            corp = bundle.corporation
            return true if !bundle.presidents_share || bundle.percent >= corp.presidents_percent

            max_shares = corp.player_share_holders.reject { |p, _| p == entity }.values.max || 0
            return true if max_shares >= corp.presidents_percent

            diff = bundle.shares.sum(&:percent) - bundle.percent

            pool_shares = @game.share_pool.percent_of(corp) || 0
            pool_shares >= diff
          end

          def process_par(action)
            corporation = action.corporation
            @game.convert_to_incremental!(corporation)
            corporation.tokens.pop # 3 -> 2
            raise GameError, 'Wrong number of tokens for Unchartered Company' if corporation.tokens.size != 2

            super
          end

          def visible_corporations
            @game.sorted_corporations
          end

          def get_par_prices(entity, _corp)
            @game.repar_prices.select { |p| p.price * 3 <= entity.cash }
          end

          def must_sell?(entity)
            return false unless can_sell_any?(entity)
            return true if @game.num_certs(entity) > @game.cert_limit && !@game.lner

            !@game.can_hold_above_corp_limit?(entity) &&
              @game.corporations.any? { |corp| !corp.holding_ok?(entity) }
          end
        end
      end
    end
  end
end
