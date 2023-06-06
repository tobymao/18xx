# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/share_buying'
require_relative 'corp_start'

module Engine
  module Game
    module G1841
      module Step
        class CorporateBuySellParShares < Engine::Step::Base
          include CorpStart
          include Engine::Step::ShareBuying

          MAX_CERTS_PER_CORP = 5
          PURCHASE_ACTIONS = [Action::BuyShares, Action::Par].freeze

          def round_state
            super.merge(
            {
              # What the corporation has sold since the start of the round
              stock_sold: {},
              # Actions taken by the player on this turn
              current_stock_actions: [],
              # What company was parred
              corp_started: nil,
            }
          )
          end

          def setup
            super
            @round.stock_sold = {}
            @round.current_stock_actions = []
            @round.corp_started = nil
          end

          def actions(entity)
            return [] unless entity == current_entity

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)

            actions << 'pass' if actions.any?
            actions
          end

          def description
            'Corporate Sell then Buy Shares'
          end

          def pass!
            super
            post_share_pass_step! if @round.corp_started
          end

          def log_pass(entity)
            if @round.corp_started
              @log << "#{entity.name} declines to purchase additional shares of #{@round.corp_started.name}"
              return
            end

            return @log << "#{entity.name} passes" if @round.current_stock_actions.empty?
            return if bought? && sold?

            action = bought? ? 'to sell' : 'to buy'
            @log << "#{entity.name} declines #{action} shares"
          end

          def pass_description
            if @round.current_stock_actions.empty?
              'Pass (Corporate Share)'
            else
              'Done (Corporate Share)'
            end
          end

          def log_skip(entity)
            @log << "#{entity.name} has no valid actions and passes"
          end

          # FIXME
          def must_sell?(_entity)
            nil
          end

          def can_sell_any?(entity)
            entity.corporate_shares.select { |share| can_sell?(entity, share.to_bundle) }.any? ||
              entity.ipo_shares.select { |share| can_sell?(entity, share.to_bundle) }.any?
          end

          def can_sell?(entity, bundle)
            return unless bundle
            return false if entity != bundle.owner

            timing = @game.check_sale_timing(entity, bundle)
            timing &&
              !bought? &&
              @game.share_pool.fit_in_bank?(bundle) &&
              bundle.can_dump?(entity)
          end

          def can_buy_any?(entity)
            can_buy_any_from_market?(entity) || can_buy_any_from_ipo?(entity)
          end

          def can_buy_any_from_market?(entity)
            @game.share_pool.shares.any? { |s| can_buy?(entity, s.to_bundle) }
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if corporation.shares.any? { |s| can_buy?(entity, s.to_bundle) }
            end

            false
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return unless bundle.buyable
            return if entity == bundle.corporation
            return if bundle.owner.corporation? && bundle.owner != bundle.corporation

            corporation = bundle.corporation
            entity.cash >= bundle.price &&
              !@round.stock_sold[corporation] &&
              (can_buy_multiple?(entity, corporation, bundle.owner) || !bought?) &&
              can_gain?(entity, bundle)
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation

            # can't buy controlling corp
            !@game.in_chain?(entity, corporation) &&
              # can't allow buyer to have more than 5 certs of a given corporation
              (@game.num_certs(entity) < @game.cert_limit(entity)) &&
              # can't allow player to control too much
              ((@game.player_controlled_percentage(entity,
                                                   corporation) + bundle.common_percent) <= corporation.max_ownership_percent)
          end

          def can_buy_multiple?(entity, corporation, _owner)
            @round.current_stock_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation } &&
              entity.percent_of(corporation) < 40
          end

          def bought?
            @round.current_stock_actions.any? { |x| self.class::PURCHASE_ACTIONS.include?(x.class) }
          end

          def sold?
            @round.current_stock_actions.any? { |x| x.instance_of?(Action::SellShares) }
          end

          def process_sell_shares(action)
            sell_shares(action.entity, action.bundle, swap: action.swap)
            track_action(action, action.bundle.corporation)
          end

          def track_action(action, _corporation)
            @round.current_stock_actions << action
          end

          def sell_shares(entity, shares, swap: nil)
            raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap

            old_frozen = @game.frozen_corporations
            @round.stock_sold[shares.corporation] = true
            @game.sell_shares_and_change_price(shares, swap: swap)
            @game.update_frozen!
            return if @game.frozen_corporations.none? { |c| !old_frozen.include?(c) }

            raise GameError, 'Cannot sell if it causes a circular chain of ownership'
          end

          def process_buy_shares(action)
            buy_shares(action.entity, action.bundle)
            track_action(action, action.bundle.corporation)
            @game.update_frozen!
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            @round.corp_started = corporation
            entity = action.entity
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, entity)

            @game.stock_market.set_par(corporation, share_price)
            share = corporation.ipo_shares.first
            buy_shares(entity, share.to_bundle)
            @game.after_par(corporation)
            track_action(action, action.corporation)
          end

          def ipo_type(_entity)
            :par
          end

          def get_par_prices(entity, _corp)
            @game
              .stock_market
              .par_prices
              .select { |p| p.price * 2 <= entity.cash }
          end
        end
      end
    end
  end
end
