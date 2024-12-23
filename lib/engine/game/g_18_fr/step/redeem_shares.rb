# frozen_string_literal: true

module Engine
  module Game
    module G18FR
      module Step
        class RedeemShares < G18FR::Step::BuySellParShares
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            available_actions = []
            available_actions << 'take_loan' if @game.can_take_loan?(entity) && !@corporate_action.is_a?(Action::BuyShares)
            available_actions << 'buy_shares' unless @game.redeemable_shares(entity).empty?
            available_actions << 'pass' if !available_actions.empty?

            available_actions
          end

          def description
            'Take Loans and Redeem Shares'
          end

          def pass_description
            'Pass'
          end

          def sellable_bundles(player, corporation)
            # Don't show sell share buttons
            []
          end

          def process_take_loan(action)
            @round.loan_taken = true

            super
          end

          def process_buy_shares(action)
            @round.share_redeemed = true

            super
          end
        end
      end
    end
  end
end
