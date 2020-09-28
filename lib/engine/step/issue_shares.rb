# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class IssueShares < Base
      def actions(entity)
        available_actions = []
        return available_actions unless entity.corporation?
        return available_actions if entity != current_entity

        available_actions << 'buy_shares' unless redeemable_shares(entity).empty?
        available_actions << 'sell_shares' unless issuable_shares(entity).empty?
        available_actions << 'pass' if blocking? && !available_actions.empty?

        available_actions
      end

      def description
        'Issue or Redeem Shares'
      end

      def pass_description
        'Skip (Issue/Redeem)'
      end

      def process_sell_shares(action)
        @game.share_pool.sell_shares(action.bundle)
        pass!
      end

      def process_buy_shares(action)
        @game.share_pool.buy_shares(action.entity, action.bundle)
        pass!
      end

      def issuable_shares(entity)
        # Done via Sell Shares
        @game.issuable_shares(entity)
      end

      def redeemable_shares(entity)
        # Done via Buy Shares
        @game.redeemable_shares(entity)
      end
    end
  end
end
