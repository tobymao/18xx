# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1870
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          # Possible pars after reissuing, with their coordinates on the stock market
          ISSUE_PAR_PRICES = [68, 72, 76, 82, 90, 100, 110, 120, 140, 160, 180, 200].freeze
          def actions(entity)
            return [] if @round.current_actions.last&.entity&.corporation?

            if entity.corporation? && entity.owned_by?(current_entity)
              actions = []
              actions << 'buy_shares' if @round.current_actions.none? &&
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
            entity.player_share_holders.reject { |p, v| (p == entity.owner && v == max) || v.zero? }
              .map { |p, _| Engine::ShareBundle.new(p.shares_of(entity).reject(&:president).first) }
          end

          def issuable_shares(entity)
            bundle = Engine::ShareBundle.new(entity.shares_of(entity))
            bundle.share_price = issue_par(entity)

            [bundle]
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return unless bundle.buyable

            return super unless entity.corporation?

            entity.cash >= bundle.price && redeemable_shares(entity).include?(bundle)
          end

          def can_sell?(entity, bundle)
            super && bundle.corporation.holding_ok?(entity, -bundle.percent)
          end

          def issue_par(corporation)
            ISSUE_PAR_PRICES
              .reject { |v| v > 0.75 * corporation.share_price.price }
              .concat([corporation.par_price.price])
              .max
          end

          def process_buy_shares(action)
            super
            return unless action.entity.corporation?

            action.bundle.shares.first.buyable = false
            @round.redeem_cash[action.entity] = 0
          end

          def process_sell_shares(action)
            return super unless action.entity.corporation?

            corporation = action.entity

            @log << "#{corporation.name} reissues #{@game.share_pool.num_presentation(action.bundle)}"

            new_par = issue_par(corporation)
            if new_par > corporation.par_price.price
              corporation.par_price = @game.find_share_price(new_par)
              @log << "#{corporation.name}'s par price is now #{@game.format_currency(new_par)}"
            end
            corporation.capitalization = :incremental
            @game.reissued[corporation] = true

            action.bundle.shares.each do |s|
              s.buyable = true
            end

            track_action(action, corporation)
          end
        end
      end
    end
  end
end
