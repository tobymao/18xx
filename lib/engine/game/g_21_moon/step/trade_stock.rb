# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G21Moon
      module Step
        class TradeStock < Engine::Step::Base
          def actions(entity)
            return [] unless entity == pending_entity

            %w[choose]
          end

          def active_entities
            [pending_entity]
          end

          def round_state
            super.merge(
              {
                pending_trades: [],
                traded_shares: {},
              }
            )
          end

          def active?
            pending_entity
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            pending_trade[:entity]
          end

          def pending_bundle
            pending_trade[:bundle]
          end

          def pending_trade
            @round.pending_trades&.first || {}
          end

          def description
            "Pick share to trade for #{pending_bundle.corporation.name}"
          end

          def choice_available?(entity)
            entity == pending_entity
          end

          def choice_name
            "Share to trade for a share of #{pending_bundle.corporation.name}"
          end

          def choices
            available_shares(pending_entity, pending_bundle).to_h do |s|
              [s.corporation.name, s.corporation.name]
            end
          end

          def available_shares(entity, trade_bundle)
            @game.corporations.map do |corp|
              next if corp == trade_bundle.corporation

              share = entity.shares_of(corp)
                .select { |s| can_dump?(entity, s) && !@round.traded_shares[s] }.min_by(&:percent)
              next unless share

              share
            end.compact
          end

          def can_sell?(_entity, _bundle)
            false
          end

          def can_dump?(entity, share)
            return true unless share.president

            sh = share.corporation.player_share_holders
            (sh.reject { |k, _| k == entity }.values.max || 0) >= share.percent
          end

          def can_dump_bundle?(entity, bundle)
            return true unless bundle.presidents_share

            sh = bundle.corporation.player_share_holders
            (sh.reject { |k, _| k == entity }.values.max || 0) >= bundle.presidents_share.percent
          end

          def outgoing_bundles(player, corporation)
            shares = player.shares_of(corporation).reject { |s| @round.traded_shares[s] }
            bundles = @game.all_bundles_for_corporation(player, corporation, shares: shares)
            bundles.select { |bundle| can_dump_bundle?(player, bundle) }
          end

          def ipo_type(_entity)
            :par
          end

          def process_choose(action)
            # do the trade as two separate actions
            player = pending_entity
            incoming = pending_bundle
            trader = incoming.owner
            outgoing = outgoing_bundles(player, @game.corporation_by_id(action.choice.to_s)).first
            raise GameError, "bundle for #{action.choice} not found" unless outgoing

            @log << "#{player.name} trades a share of #{outgoing.corporation.name} for a share of "\
                    "#{incoming.corporation.name} with #{trader.name}"

            @game.share_pool.buy_shares(player, incoming, exchange: true)

            # the other direction has to be broken into pieces because of a possible president change
            # we also have to prevent the corporation from becoming president
            #
            old_trader_shares = trader.shares_of(outgoing.corporation).dup
            outgoing.share_price = 0
            @game.share_pool.sell_shares(outgoing, silent: true)

            # outgoing and actual_outgoing are different when a president transfer was involved
            new_outgoing = @game.share_pool.shares_of(outgoing.corporation).last
            @game.share_pool.buy_shares(trader, new_outgoing, exchange: true, allow_president_change: false)
            new_trader_shares = trader.shares_of(outgoing.corporation)
            actual_outgoing = (new_trader_shares - old_trader_shares)&.first

            raise GameError, 'Incoming bundle wrong size' unless incoming.shares.one?
            raise GameError, 'Outgoing share missing' unless actual_outgoing

            @round.traded_shares[incoming.shares.first] = true
            @round.traded_shares[actual_outgoing] = true

            @round.pending_trades.shift
          end
        end
      end
    end
  end
end
