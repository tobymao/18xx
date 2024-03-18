# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G21Moon
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return [] unless @round.pending_trades.empty?

            super
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.ipo_shares.first&.to_bundle)
            end
          end

          def can_buy_any?(entity)
            (can_buy_any_from_market?(entity) ||
             can_buy_any_from_ipo?(entity) ||
             can_trade_any?(entity))
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if can_buy_shares?(entity, corporation.ipo_shares)
            end

            false
          end

          def can_trade_any?(entity)
            return false unless can_trade_for_share_from?(entity)

            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              next unless corporation.owner == entity

              return true if can_trade_shares?(entity, corporation.corporate_shares)
            end

            false
          end

          def can_trade_shares?(entity, shares)
            return if shares.empty? || bought?
            return if shares.all? { |s| @round.traded_shares[s] }

            !@round.players_sold[entity][shares.first.corporation]
          end

          def can_trade_for_share_from?(entity)
            @game.corporations.any? do |corporation|
              bundles = tradeable_bundles(entity, corporation)
              bundles.any? { |bundle| can_dump?(entity, bundle) }
            end
          end

          def tradeable_bundles(player, corporation)
            shares = player.shares_of(corporation).reject { |s| @round.traded_shares[s] }
            @game.all_bundles_for_corporation(player, corporation, shares: shares)
          end

          def can_buy?(entity, bundle)
            return can_get_in_trade?(entity, bundle) if bundle&.owner&.corporation?

            super
          end

          def can_get_in_trade?(entity, bundle)
            return unless bundle&.buyable
            return if @round.traded_shares[bundle.shares[0]]
            return unless bundle.owner.owner == entity
            return unless can_trade_for_share_from?(entity)

            # ignore holding percent limit on trades
            corporation = bundle.corporation
            !@round.players_sold[entity][corporation]
          end

          def process_buy_shares(action)
            return start_trade(action) if action&.bundle&.owner&.corporation?

            super
          end

          def start_trade(action)
            @log << "#{action.entity.name} starts a trade for a share of #{action.bundle.corporation.name}"

            track_action(action, action.bundle.corporation)

            @round.pending_trades << {
              entity: action.entity,
              bundle: action.bundle,
            }

            @round.clear_cache!
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil,
                         discounter: nil)
            corp = shares.corporation
            if shares.owner == corp.ipo_owner
              # IPO shares pay corporation
              @game.share_pool.buy_shares(entity,
                                          shares,
                                          exchange: exchange,
                                          swap: swap,
                                          allow_president_change: allow_president_change)
              price = corp.share_price.price * shares.num_shares
              @game.bank.spend(price, corp)
            else
              super
            end
          end

          # don't look at corporate holdings, only players
          def can_dump?(entity, bundle)
            return true unless bundle.presidents_share

            sh = bundle.corporation.player_share_holders
            (sh.reject { |k, _| k == entity }.values.max || 0) >= bundle.presidents_share.percent
          end

          def corporate_buy_text(_share)
            'Trade for'
          end

          def must_sell?(entity)
            @game.num_certs(entity) > @game.cert_limit
          end

          def share_flags(shares)
            return if shares.empty?
            return 'T' if shares.all? { |s| @round.traded_shares[s] }
            return 't' if shares.any? { |s| @round.traded_shares[s] }
          end

          def pool_shares(corporation)
            @game.share_pool.shares_by_corporation[corporation].group_by(&:percent).values
                           .map { |shares| best_to_buy(shares) }.sort_by(&:percent).reverse
          end

          # first try to return an untraded share, then any
          def best_to_buy(shares)
            untraded = shares.find { |s| !@round.traded_shares[s] }
            return untraded if untraded

            shares.first
          end

          # Bias toward selling traded shares first
          def sellable_bundles(seller, corp)
            shares = seller.shares_of(corp).sort_by { |s| [s.president ? 1 : 0, @round.traded_shares[s] ? 0 : 1] }
            bundles = @game.all_bundles_for_corporation(seller, corp, shares: shares)
            bundles.select { |bundle| can_sell?(seller, bundle) }
          end
        end
      end
    end
  end
end
