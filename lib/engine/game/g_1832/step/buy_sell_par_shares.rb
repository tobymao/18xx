# frozen_string_literal: true

require_relative '../../g_1870/step/buy_sell_par_shares'

module Engine
  module Game
    module G1832
      module Step
        class BuySellParShares < G1870::Step::BuySellParShares
          # A corporation or system may hold at most 40% of itself through redemption.
          MAX_TREASURY_PERCENT = 40
          MAX_REDEMPTION_PERCENT = 10

          def visible_corporations
            @game.sorted_corporations.reject { |item| item.type == :system unless item.floated? }
          end

          def round_state
            super.merge(redeemed_percent: Hash.new(0))
          end

          def actions(entity)
            return corporate_actions(entity) if entity.corporation? && entity.owned_by?(current_entity)

            actions = super
            actions << 'pass' if entity.player? && actions.empty? && players_corporations_have_actions?(entity)
            actions
          end

          # 1870 offers a redemption while the corporation holds fewer than four shares, which is 40%
          # only when a share is 10%. A system's shares are 5%, so count the treasury in percent.
          def corporate_actions(entity)
            return [] if @round.current_actions.last&.entity&.corporation?

            actions = []
            actions << 'buy_shares' if @round.current_actions.none? &&
                                       entity.operated? &&
                                       !redeemable_shares(entity).empty?

            shares = entity.shares_of(entity)
            actions << 'sell_shares' if shares.any? && shares.none?(&:buyable)
            actions
          end

          # Without this a player who can only act through a corporation would be skipped.
          def players_corporations_have_actions?(player)
            @game.corporations.any? { |c| c.owner == player && !corporate_actions(c).empty? }
          end

          def redeemable_shares(entity)
            return [] if !entity.corporation? || entity.share_price.price > @round.redeem_cash[entity]

            market_shares = @game.share_pool.shares_of(entity)
            bundles = if market_shares.empty?
                        redeemable_from_players(entity)
                      else
                        share = redeemable_market_share(entity, market_shares)
                        share ? [ShareBundle.new(share)] : []
                      end

            bundles.select { |bundle| within_redemption_limits?(entity, bundle) }
          end

          def process_buy_shares(action)
            corporation = action.entity.corporation? ? action.entity : nil
            budget = @round.redeem_cash[corporation] if corporation
            super
            return unless corporation

            @round.redeemed_percent[corporation] += action.bundle.percent
            # 1870 spends the whole redemption budget on the first redemption; a system keeps the rest for its second.
            @round.redeem_cash[corporation] = budget - action.bundle.price if redemptions_left?(corporation)
          end

          private

          def redeemable_market_share(corporation, shares)
            certificates = shares.reject(&:president)
            regular = certificates.reject { |share| corporation.vice_president_certs.include?(share) }
            (regular.empty? ? certificates : regular).min_by(&:percent)
          end

          def redeemable_from_players(corporation)
            holders = corporation.player_share_holders.keys
            regular = holders.filter_map { |player| redeemable_from_player(corporation, player, vice_president: false) }
            return regular unless regular.empty?

            holders.filter_map { |player| redeemable_from_player(corporation, player, vice_president: true) }
          end

          def redeemable_from_player(corporation, player, vice_president:)
            certificates = player.shares_of(corporation).reject(&:president)
            share = certificates.select { |s| corporation.vice_president_certs.include?(s) == vice_president }.min_by(&:percent)
            return unless share

            bundle = ShareBundle.new(share)
            bundle if player != corporation.owner || @game.keeps_presidency_after_sale?(player, bundle)
          end

          def within_redemption_limits?(corporation, bundle)
            @round.redeemed_percent[corporation] + bundle.percent <= MAX_REDEMPTION_PERCENT &&
              treasury_percent(corporation) + bundle.percent <= MAX_TREASURY_PERCENT
          end

          def treasury_percent(entity)
            entity.shares_of(entity).sum(&:percent)
          end

          # A corporation may redeem 10% of itself per stock round: one share, or for a system a vice-president
          # certificate or two 5% shares (one per turn, which the 1870 step already enforces).
          def redemptions_left?(entity)
            @round.redeemed_percent[entity] < MAX_REDEMPTION_PERCENT
          end
        end
      end
    end
  end
end
