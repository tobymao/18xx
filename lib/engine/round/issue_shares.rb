# frozen_string_literal: true

module Engine
  module Round
    module IssueShares
      def process_sell_shares(action)
        return super if action.entity.player?

        @game.share_pool.sell_shares(action.bundle)
      end

      def process_buy_shares(action)
        @game.share_pool.buy_shares(@current_entity, action.bundle)
      end

      def issuable_shares
        num_shares = @current_entity.num_player_shares - @current_entity.num_market_shares
        bundles = @current_entity.bundles_for_corporation(@current_entity)
        share_price = @game.stock_market.find_share_price(@current_entity, :left).price

        bundles
          .each { |bundle| bundle.share_price = share_price }
          .reject { |bundle| bundle.num_shares > num_shares }
      end

      def redeemable_shares
        share_price = @game.stock_market.find_share_price(@current_entity, :right).price

        @game
          .share_pool
          .bundles_for_corporation(@current_entity)
          .each { |bundle| bundle.share_price = share_price }
          .reject { |bundle| @current_entity.cash < bundle.price }
      end
    end
  end
end
