# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class IssueShares < Base
      ACTIONS = %w[buy_shares sell_shares pass].freeze
      ACTIONS_NO_PASS = %w[buy_shares sell_shares].freeze

      def actions(entity)
        return [] unless entity.corporation?
        return [] if redeemable_shares(entity).empty? && issuable_shares(entity).empty?
        return [] if entity != current_entity

        blocking? ? ACTIONS : ACTIONS_NO_PASS
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
