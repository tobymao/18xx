# frozen_string_literal: true

require_relative 'buy_sell_par_shares'
require_relative 'passable_auction'

module Engine
  module Step
    class BuySellParSharesViaBid < BuySellParShares
      # Common code between 1867 and 18Ireland for auctioning corporations via bid
      include Engine::Step::PassableAuction

      def actions(entity)
        return [] unless entity == current_entity
        return %w[bid pass] if @auctioning

        actions = super
        actions << 'bid' if !bought? && can_bid?(entity)
        actions << 'pass' if actions.any? && !actions.include?('pass') && !must_sell?(entity)
        actions
      end

      def auctioning_corporation
        return @winning_bid.corporation if @winning_bid

        @auctioning
      end

      def normal_pass?(_entity)
        !@auctioning
      end

      def active_entities
        return super unless @auctioning

        [@active_bidders[(@active_bidders.index(highest_bid(@auctioning).entity) + 1) % @active_bidders.size]]
      end

      def log_pass(entity)
        return if @auctioning

        super
      end

      def pass!
        return super unless @auctioning

        pass_auction(current_entity)
        resolve_bids
      end

      def process_bid(action)
        if auctioning
          add_bid(action)
        else
          selection_bid(action)
        end
      end

      def add_bid(action)
        entity = action.entity
        corporation = action.corporation
        price = action.price

        if @auctioning
          @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
        else
          @log << "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
          @game.place_home_token(action.corporation)
        end
        super(action)

        resolve_bids
      end

      def min_bid(corporation)
        return self.class::MIN_BID unless @auctioning

        highest_bid(corporation).price + min_increment
      end

      def max_bid(player, corporation = nil)
        # player cannot bid if they are at cert limit
        return 0 if corporation && !can_gain?(player, corporation.shares.first&.to_bundle)

        player.cash
      end

      def pass_description
        if @auctioning
          'Pass (Bid)'
        else
          super
        end
      end

      def setup
        setup_auction
        super
      end
    end
  end
end
