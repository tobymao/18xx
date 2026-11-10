# frozen_string_literal: true

require_relative '../../g_1870/step/buy_sell_par_shares'

module Engine
  module Game
    module G1832
      module Step
        class BuySellParShares < G1870::Step::BuySellParShares
          # A corporation or system may hold at most 40% of itself through redemption.
          MAX_TREASURY_PERCENT = 40

          def visible_corporations
            @game.sorted_corporations.reject { |item| item.type == :system unless item.floated? }
          end

          def round_state
            super.merge(redemptions: Hash.new(0))
          end

          # 1870 offers a redemption while the corporation holds fewer than four shares, which is 40%
          # only when a share is 10%. A system's shares are 5%, so count the treasury in percent.
          def actions(entity)
            actions = super
            return actions unless redeeming?(entity)

            actions = actions.reject { |action| action == 'buy_shares' }
            actions.unshift('buy_shares') if @round.current_actions.none? && entity.operated? && can_redeem_more?(entity)
            actions
          end

          def can_buy?(entity, bundle)
            return super unless entity.corporation?

            super && redemptions_left?(entity) && treasury_percent(entity) + bundle.percent <= MAX_TREASURY_PERCENT
          end

          def process_buy_shares(action)
            corporation = action.entity.corporation? ? action.entity : nil
            budget = @round.redeem_cash[corporation] if corporation
            super
            return unless corporation

            @round.redemptions[corporation] += 1
            # 1870 spends the whole redemption budget on the first redemption; a system keeps the rest for its second.
            @round.redeem_cash[corporation] = budget - action.bundle.price if redemptions_left?(corporation)
          end

          private

          def redeeming?(entity)
            entity.corporation? && entity.owned_by?(current_entity) && !@round.current_actions.last&.entity&.corporation?
          end

          def can_redeem_more?(entity)
            treasury_percent(entity) < MAX_TREASURY_PERCENT && redemptions_left?(entity)
          end

          def treasury_percent(entity)
            entity.shares_of(entity).sum(&:percent)
          end

          # A corporation may redeem one share per stock round, a system two (one per turn, which the
          # 1870 step already enforces).
          def redemptions_left?(entity)
            @round.redemptions[entity] < (@game.system?(entity) ? 2 : 1)
          end
        end
      end
    end
  end
end
