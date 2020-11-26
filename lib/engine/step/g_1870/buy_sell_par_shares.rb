# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1870
      class BuySellParShares < BuySellParShares
        POSSIBLE_PARS = {
          72 => [5, 7],
          76 => [4, 7],
          82 => [3, 7],
          90 => [2, 7],
          100 => [1, 7],
          110 => [1, 8],
          120 => [1, 9],
          140 => [1, 10],
          160 => [1, 11],
          180 => [1, 12],
          200 => [1, 13],
        }.freeze

        def actions(entity)
          return [] if @current_actions.last&.entity&.corporation?

          if entity.corporation? && entity.owned_by?(current_entity)
            actions = []
            actions << 'buy_shares' if @current_actions.none? &&
                                       entity.operated? &&
                                       entity.num_ipo_shares < 4

            shares = entity.shares_of(entity)
            actions << 'sell_shares' unless shares.none? || shares.any?(&:buyable)

            return actions
          end

          super
        end

        def round_state
          super.merge(redeem_cash: Hash.new { |h, c| h[c] = c.cash })
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation? && entity.share_price.price <= @round.redeem_cash[entity]

          bank_share = @game.share_pool.shares_of(entity).first
          return [Engine::ShareBundle.new(bank_share)] if bank_share

          max = entity.player_share_holders.reject { |p, _| p == entity.owner }.values.max
          entity.player_share_holders.reject { |p, v| p == entity.owner && v == max || v.zero? }
            .map { |p, _| Engine::ShareBundle.new(p.shares_of(entity).reject(&:president).first) }
        end

        def issuable_shares(entity)
          [Engine::ShareBundle.new(entity.shares_of(entity))]
        end

        def can_buy?(entity, bundle)
          return unless bundle
          return unless bundle.buyable

          if entity.corporation?
            entity.cash >= bundle.price && redeemable_shares(entity).include?(bundle)
          else
            super
          end
        end

        def process_buy_shares(action)
          super
          return unless action.entity.corporation?

          action.bundle.shares.first.buyable = false
          @round.redeem_cash[action.entity] = 0
        end

        def process_sell_shares(action)
          action.bundle.shares.each do |s|
            s.buyable = true
          end

          @log << "#{action.entity.name} reissues #{@game.share_pool.num_presentation(action.bundle)}"

          action.entity.capitalization = :incremental

          new_par = POSSIBLE_PARS.keys.reject { |v| v > 0.75 * action.entity.share_price.price }
          if new_par.size.positive? && new_par.max > action.entity.par_price.price
            action.entity.par_price = @game.stock_market.share_price(*(POSSIBLE_PARS[new_par.max]))

            @log << "#{action.entity.name}'s par price is now #{@game.format_currency(action.entity.par_price.price)}"
          end

          @round.last_to_act = action.entity
          @current_actions << action
        end
      end
    end
  end
end
