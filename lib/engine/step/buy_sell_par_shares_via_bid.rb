# frozen_string_literal: true

require_relative 'buy_sell_par_shares'
require_relative 'passable_auction'

module Engine
  module Step
    class BuySellParSharesViaBid < BuySellParShares
      # Common code between 1867, 18Ireland, and 1877: Stockholm Tramways for auctioning corporations via bid
      # Can also be used to auction private companies.
      include Engine::Step::PassableAuction

      def actions(entity)
        return [] unless entity == current_entity
        return %w[bid pass] if @auctioning

        actions = super
        actions << 'bid' if !bought? && can_bid?(entity)
        actions << 'pass' if actions.any? && !actions.include?('pass') && !must_sell?(entity)
        actions
      end

      def auctioning_company
        @auctioning
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
        player = action.entity
        entity = action.corporation || action.company
        price = action.price

        if @auctioning
          @log << "#{player.name} bids #{@game.format_currency(price)} for #{entity.name}"
        else
          @log << "#{player.name} auctions #{entity.name} for #{@game.format_currency(price)}"
          @game.place_home_token(entity) if (@game.class::HOME_TOKEN_TIMING == :par) && !entity.company?
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
        elsif @round.current_actions.empty?
          'Pass (Share)'
        else
          'Done (Share)'
        end
      end

      def setup
        setup_auction
        super
      end
    end
  end
end
