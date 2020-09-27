# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Auctioner
      ##
      # Auctioner keeps track of multiple auctions and provides utilities for auctions
      # It does not apply any logic on its own
      #
      # Call setup_auction to initialize as part of setup
      # Uses the following variables
      # @bids - Dict containing companies (or other things), then player entities and their bids

      attr_reader :bids

      def pass_description
        if auctioning
          "Pass (on #{auctioning.id})"
        else
          'Pass'
        end
      end

      def visible?
        true
      end

      def players_visible?
        true
      end

      def pass_auction(entity)
        @log << "#{entity.name} passes on #{auctioning.name}"

        @bids[auctioning]&.reject! do |bid|
          bid.entity == entity
        end
        resolve_bids
      end

      def min_increment
        @game.class::MIN_BID_INCREMENT
      end

      def setup_auction
        @bids = Hash.new { |h, k| h[k] = [] }
      end

      def may_choose?(_company)
        false
      end

      def current_bid_amount(player, company)
        bids[company]&.find { |b| b.entity == player }&.price || 0
      end

      def min_bid(_company)
        # Minimum a bid that an entity can bid
        raise NotImplementedError
      end

      def max_bid(_entity, _company)
        # Maximum that a bid can be increased to by an entity
        raise NotImplementedError
      end

      protected

      def auctioning
        active_bids { |company, _| company }
      end

      def highest_bid(company)
        @bids[company].max_by(&:price)
      end

      def add_bid(bid)
        company = bid.company || bid.corporation
        entity = bid.entity
        price = bid.price
        min = min_bid(company)
        @game.game_error("Minimum bid is #{@game.format_currency(min)} for #{company.name}") if price < min
        if @game.class::MUST_BID_INCREMENT_MULTIPLE && ((price - min) % @game.class::MIN_BID_INCREMENT).nonzero?
          @game.game_error("Must increase bid by a multiple of #{@game.class::MIN_BID_INCREMENT}")
        end
        if price > max_bid(entity, company)
          @game.game_error("Cannot afford bid. Maximum possible bid is #{max_bid(entity, company)}")
        end
        bids = @bids[company]
        bids.reject! { |b| b.entity == entity }
        bids << bid
      end

      def bids_for_player(player)
        @bids.values.map do |bids|
          bids.find { |bid| bid.entity == player }
        end.compact
      end
    end
  end
end
