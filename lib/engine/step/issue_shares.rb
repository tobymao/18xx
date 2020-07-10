# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class IssueShares < Base
      ACTIONS = %w[buy_shares sell_shares pass].freeze

      def actions(entity)
        return [] if entity.minor?
        return [] if !redeemable_shares(entity) && !issuable_shares(entity)

        ACTIONS
      end

      def description
        'Issue or Redeem Shares'
      end

      def setup
        @done_action = false
      end

      def unpass!
        super
        setup
      end

      def pass_description
        @done_action ? 'Done (Issue/Redeem)' : 'Skip (Issue/Redeem)'
      end

      def process_sell_shares(action)
        @game.share_pool.sell_shares(action.bundle)
        @done_action = true
      end

      def process_buy_shares(action)
        @game.share_pool.buy_shares(action.entity, action.bundle)
        @done_action = true
      end

      def issuable_shares(entity)
        # Done via Sell Shares
        num_shares = entity.num_player_shares - entity.num_market_shares
        bundles = entity.bundles_for_corporation(entity)
        share_price = @game.stock_market.find_share_price(entity, :left).price

        bundles
          .each { |bundle| bundle.share_price = share_price }
          .reject { |bundle| bundle.num_shares > num_shares }
      end

      def redeemable_shares(entity)
        # Done via Buy Shares
        share_price = @game.stock_market.find_share_price(entity, :right).price

        @game
          .share_pool
          .bundles_for_corporation(entity)
          .each { |bundle| bundle.share_price = share_price }
          .reject { |bundle| entity.cash < bundle.price }
      end
    end
  end
end
