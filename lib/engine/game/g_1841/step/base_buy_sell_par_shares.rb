# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/buy_shares'
require_relative '../../../action/par'
require_relative 'corp_start'

module Engine
  module Game
    module G1841
      module Step
        class BaseBuySellParShares < Engine::Step::BuySellParShares
          include CorpStart
          def description
            'Sell then Buy Shares or Concessions'
          end

          def round_state
            super.merge({ corp_started: nil })
          end

          def setup
            super
            @round.corp_started = nil
          end

          def can_buy_any_from_player?(_entity)
            false
          end

          def can_buy_multiple?(entity, corporation, _owner)
            @round.current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation } &&
              entity.percent_of(corporation) < 40
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return unless bundle.buyable
            return if bundle.owner.corporation? && bundle.owner != bundle.corporation # can't buy non-IPO shares in treasury
            return if bundle.owner.player? && entity.player? && !@game.allow_player2player_sales?
            return if bundle.owner.player? && entity.corporation?

            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation

            # can't exceed cert limit
            (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity)) &&
              # can't allow player to control too much
              ((@game.player_controlled_percentage(entity,
                                                   corporation) + bundle.common_percent) <= corporation.max_ownership_percent)
          end

          def can_dump?(entity, bundle)
            super && (!bundle.presidents_share || @game.pres_change_ok?(bundle.corporation))
          end

          def pass!
            super
            post_share_pass_step! if @round.corp_started
          end

          def log_pass(entity)
            return super unless @round.corp_started

            @log << "#{entity.name} declines to purchase additional shares of #{@round.corp_started.name}"
          end

          def can_sell_any_of_corporation?(entity, corporation)
            bundles = @game.bundles_for_corporation(entity, corporation).reject { |b| b.corporation == entity }
            bundles.any? { |bundle| can_sell?(entity, bundle) }
          end

          # include anti-trust rule
          def must_sell?(entity)
            return false unless can_sell_any?(entity)
            return true if @game.num_certs(entity) > @game.cert_limit(entity)

            player = @game.controller(entity)
            @game.corporations.any? do |corp|
              (@game.player_controlled_percentage(player, corp) > corp.max_ownership_percent) &&
                can_sell_any_of_corporation?(entity, corp)
            end
          end

          def sell_shares(entity, shares, swap: nil)
            old_circular = @game.circular_corporations
            raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap

            @round.players_sold[shares.owner][shares.corporation] = :now
            @game.sell_shares_and_change_price(shares, swap: swap,
                                                       allow_president_change: @game.pres_change_ok?(shares.corporation))
            @game.update_frozen!
            @round.recalculate_order if @round.respond_to?(:recalculate_order)
            return if @game.circular_corporations.none? { |c| !old_circular.include?(c) }

            raise GameError, 'Cannot sell if it causes a circular chain of ownership'
          end

          def process_buy_shares(action)
            old_circular = @game.circular_corporations
            @round.players_bought[action.entity][action.bundle.corporation] += action.bundle.percent
            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.purchase_for || action.entity, action.bundle,
                       swap: action.swap, borrow_from: action.borrow_from,
                       allow_president_change: @game.pres_change_ok?(action.bundle.corporation))
            track_action(action, action.bundle.corporation)
            @game.update_frozen!
            return if @game.circular_corporations.none? { |c| !old_circular.include?(c) }

            raise GameError, 'Cannot purchase if it causes a circular chain of ownership'
          end

          def get_par_prices(entity, corp)
            return super if corp.type == :major

            @game
              .stock_market
              .par_prices
              .select { |p| p.type == :par && p.price * 2 <= entity.cash }
          end

          def process_par(action)
            @round.corp_started = action.corporation
            super
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| c.closed? || (@game.historical?(c) && !@game.startable?(c)) }
          end
        end
      end
    end
  end
end
