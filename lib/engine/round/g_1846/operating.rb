# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1846
      class Operating < Operating
        STEPS = %i[
          issue
          token_or_track
          route
          dividend
          train
          company
        ].freeze

        STEP_DESCRIPTION = {
          issue: 'Issue or Redeem Shares',
          token_or_track: 'Place a Token or Lay Track',
          route: 'Run Routes',
          dividend: 'Pay or Withold Dividends',
          train: 'Buy Trains',
          company: 'Purchase Companies',
        }.freeze

        SHORT_STEP_DESCRIPTION = {
          issue: 'Issue/Redeem',
          token_or_track: 'Token/Track',
          route: 'Routes',
          train: 'Train',
          company: 'Company',
        }.freeze

        def can_lay_track?
          @step == :token_or_track
        end

        def can_place_token?
          @step == :token_or_track
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

        private

        def ignore_action?(action)
          return false if action.is_a?(Action::SellShares) && action.entity.corporation?

          super
        end

        def skip_issue
          issuable_shares.empty? && redeemable_shares.empty?
        end

        def skip_token_or_track; end

        def process_sell_shares(action)
          return super if action.entity.player?

          @game.share_pool.sell_shares(action.bundle)
        end

        def process_buy_shares(action)
          @game.share_pool.buy_shares(@current_entity, action.bundle)
        end
      end
    end
  end
end
