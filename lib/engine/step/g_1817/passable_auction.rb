# frozen_string_literal: true

require_relative '../base'
require_relative '../auctioner'

module Engine
  module Step
    module G1817
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

        def pass_auction(entity)
          @active_bidders.delete(entity)
          super
        end

        def setup_auction
          super
          @auctioning = nil
          @active_bidders = []
        end

        protected

        def active_bids
          company = @auctioning
          bids = @bids[company]
          yield company, bids if bids.any?
        end

        def selection_bid(bid)
          add_bid(bid)
          @auctioning = bid.company || bid.corporation
          @auction_triggerer = bid.entity
          @active_bidders = entities.select do |player|
            player == @auction_triggerer || max_bid(player, @auctioning) >= min_bid(@auctioning)
          end
        end

        def add_bid(bid)
          super

          return unless @auctioning

          # Remove players who cannot afford the bid
          # This has to be two step, as pass_auction modifies active_bidder list.
          passing = @active_bidders.reject do |player|
            player == bid.entity || max_bid(player, @auctioning) >= min_bid(@auctioning)
          end
          passing.each { |player| pass_auction(player) }
        end

        def resolve_bids
          return unless @active_bidders.one?

          winner = @bids[@auctioning].first
          win_bid(winner)
          @bids.clear
          @active_bidders.clear
          @auctioning = nil
        end
      end
    end
  end
end
