# frozen_string_literal: true

require_relative 'base'
require_relative 'auctioner'

module Engine
  module Step
    module PassableAuction
      ##
      # PassableAuction adds logic on top of Auctioner.
      # It assumes that one item is up for auction (set by selection_bid)
      # It assumes that once a entity has passed they are now out of that auction until it is resolved.
      # When only one entity remains it calls resolve_bids and win_bid
      # @auctioning - Current 'company' being auctioned
      # @active_bidders - List of entities that have yet to pass on the auction
      # @auction_triggerer - Who triggered the auction

      include Auctioner

      def remove_from_auction(entity)
        @active_bidders.delete(entity)
        super
      end

      def setup_auction
        super
        @auctioning = nil
        @active_bidders = []
        @auction_triggerer = nil
      end

      def committed_cash(_player, _show_hidden = false)
        0
      end

      protected

      def active_auction
        company = @auctioning
        bids = @bids[company]
        yield company, bids unless bids.empty?
      end

      def initial_auction_entities
        entities
      end

      def auction_entity(entity)
        @auctioning = entity
        min = min_bid(@auctioning)
        @active_bidders, cannot_bid = initial_auction_entities.partition do |player|
          player == @auction_triggerer || max_bid(player, @auctioning) >= min
        end
        cannot_bid.each do |player|
          @game.log << "#{player.name} cannot bid #{@game.format_currency(min)}"\
                       " and is out of the auction for #{@auctioning.name}"
        end
        resolve_bids
      end

      def selection_bid(bid)
        add_bid(bid)
        @auction_triggerer = bid.entity
        auction_entity(bid_target(bid))
      end

      def add_bid(bid)
        super

        return unless @auctioning

        # Remove players who cannot afford the bid
        # This has to be two step, as pass_auction modifies active_bidder list.
        min = min_bid(@auctioning)
        passing = @active_bidders.reject do |player|
          player == bid.entity || max_bid(player, @auctioning) >= min
        end
        passing.each do |player|
          @game.log << "#{player.name} cannot bid #{@game.format_currency(min)}"\
                       " and is out of the auction for #{auctioning.name}"
          remove_from_auction(player)
        end
      end

      def win_bid(winner, company)
        # Don't modify @auctioning here do it in post_win_bid
      end

      def post_win_bid(winner, company)
        # Anything modifying @auctioning should be done here rather than win_bid
      end

      def resolve_bids
        return unless @auctioning

        company = @auctioning

        if @active_bidders.none?
          win_bid(nil, company)
        else
          return unless @active_bidders.one?
          return unless @bids[@auctioning].any?

          winner = @bids[@auctioning].first
          win_bid(winner, company)
        end

        @bids.clear
        @active_bidders.clear
        @auctioning = nil
        post_win_bid(winner, company)
      end
    end
  end
end
