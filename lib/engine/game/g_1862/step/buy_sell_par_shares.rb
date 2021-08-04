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

          def can_sell?(entity, bundle)
            return unless bundle

            corporation = bundle.corporation

            timing = @game.check_sale_timing(entity, corporation)

            timing &&
              !(@game.class::MUST_SELL_IN_BLOCKS && @round.players_sold[entity][corporation] == :now) &&
              can_sell_order? &&
              can_dump?(entity, bundle) &&
              check_share_timing(entity, bundle)
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

          # can't sell any shares bought this round
          def check_share_timing(entity, bundle)
            corporation = bundle.corporation
            total_shares = corporation.share_holders[entity]
            total_shares - @round.bought_shares[entity][corporation] >= bundle.percent
          end

          def process_par(action)
            corporation = action.corporation
            @game.convert_to_incremental!(corporation)
            corporation.tokens.pop # 3 -> 2
            raise GameError, 'Wrong number of tokens for Unchartered Company' if corporation.tokens.size != 2

            @round.bought_shares[action.entity][corporation] += 30
            super
          end

          def process_buy_shares(action)
            corporation = action.bundle.corporation
            @round.bought_shares[action.entity][corporation] += action.bundle.percent
            super
          end

          def visible_corporations
            @game.sorted_corporations
          end

          def get_par_prices(entity, _corp)
            @game.repar_prices.select { |p| p.price * 3 <= entity.cash }
          end

          def round_state
            super.merge(
              {
                bought_shares: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } },
              }
            )
          end
        end
      end
    end
  end
end
