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
        class BuySellParShares < Engine::Step::BuySellParShares
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

          # FIXME
          def purchasable_companies(_entity)
            []
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

          def sell_shares(entity, shares, swap: nil)
            old_frozen = @game.frozen_corporations
            raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap

            @round.players_sold[shares.owner][shares.corporation] = :now
            @game.sell_shares_and_change_price(shares, swap: swap,
                                                       allow_president_change: @game.pres_change_ok?(shares.corporation))
            @game.update_frozen!
            return if @game.frozen_corporations.none? { |c| !old_frozen.include?(c) }

            raise GameError, 'Cannot sell if it causes a circular chain of ownership'
          end

          def process_buy_shares(action)
            old_frozen = @game.frozen_corporations
            @round.players_bought[action.entity][action.bundle.corporation] += action.bundle.percent
            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.purchase_for || action.entity, action.bundle,
                       swap: action.swap, borrow_from: action.borrow_from,
                       allow_president_change: @game.pres_change_ok?(action.bundle.corporation))
            track_action(action, action.bundle.corporation)
            @game.update_frozen!
            return if @game.frozen_corporations.none? { |c| !old_frozen.include?(c) }

            raise GameError, 'Cannot purchase if it causes a circular chain of ownership'
          end

          def process_par(action)
            @round.corp_started = action.corporation
            super
          end

          def visible_corporations
            @game.corporations.reject { |c| c.closed? || (@game.historical?(c) && !@game.startable?(c)) }
          end

          def can_buy_company?(player, company)
            !bought? && super
          end

          def process_buy_company(action)
            super
            @round.last_to_act = action.entity.player
            @round.current_actions << action
          end
        end
      end
    end
  end
end
