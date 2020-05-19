# frozen_string_literal: true

require_relative '../action/par'
require_relative '../action/bid'
require_relative '../game_error'
require_relative 'base'

module Engine
  module Round
    class Auction < Base
      attr_reader :bids, :companies, :last_to_act, :min_increment

      def initialize(entities, game:, min_increment: 5)
        super
        @companies = game.companies.sort_by(&:value)
        @cheapest = @companies.first
        @bank = game.bank
        @min_increment = min_increment
        @share_pool = game.share_pool

        @bids = Hash.new { |h, k| h[k] = [] }
        @bidders = Hash.new { |h, k| h[k] = [] }

        # The player after this one will have priority deal next round
        # if everyone passes.
        @last_to_act = nil

        # The company currently up for limited auction, or nil.
        @auctioning_company = nil

        # The player who kicked off the limited auction, or nil.
        @auction_triggerer = nil

        # Used when a private company needs to par at the end of the round
        @companies_pending_par = []
      end

      def name
        'Auction Round'
      end

      def description
        'Bid on Companies'
      end

      def pass_description
        'Pass (Bidding)'
      end

      def finished?
        @end_game || (@companies.empty? && !company_pending_par)
      end

      def min_bid(company)
        return unless company
        return company.min_bid if may_purchase?(company)

        high_bid = @bids[company].max_by(&:price)
        (high_bid ? high_bid.price : company.min_bid) + @min_increment
      end

      def auction?
        true
      end

      def may_purchase?(company)
        !@auctioning_company && company == companies.first
      end

      def may_bid?(company)
        !@auctioning_company || company == @auctioning_company
      end

      def company_pending_par
        @companies_pending_par[0]
      end

      private

      def all_passed?
        @entities.all?(&:passed?)
      end

      # Process a non-pass action.
      def _process_action(action)
        case action
        when Action::Bid
          if @auctioning_company
            add_bid(action)
          else
            @last_to_act = @current_entity
            placement_bid(action)
          end
        when Action::Par
          share_price = action.share_price
          corporation = action.corporation
          @game.stock_market.set_par(corporation, share_price)
          @share_pool.buy_share(@current_entity, corporation.shares.first, exchange: :free)
          @companies_pending_par.shift
        end
      end

      # A non-pass action has been completed.
      # Everybody has a chance to act in the future so we clear their passed flags.
      def action_processed(_action)
        @entities.each(&:unpass!)
      end

      # An action (either pass or not) has been completed and we move on
      # to the next player.
      def change_entity(_action)
        return @current_entity = company_pending_par.owner if company_pending_par

        if (bids = @bids[@auctioning_company]).any?
          # There are still remaining bids on a limited auction. The
          # lowest-bidding remaining player goes next.
          @current_entity = bids.min_by(&:price).entity
        else
          # If we just exited a limited auction, move to the player after the
          # one who triggered it.
          @current_entity = @auction_triggerer if @auction_triggerer

          loop do
            @current_entity = next_entity
            break if !@current_entity.passed? || all_passed?
          end
        end
      end

      # We've already moved on to the next player at this point and just
      # need to clean up.
      def action_finalized(_action)
        @auction_triggerer = nil if @bids[@companies.first].empty? && !finished?
        return if !all_passed? || finished?

        # Everyone has passed so we need to run a fake OR.
        if @companies.include?(@cheapest)
          # No one has bought anything so we reduce the value of the cheapest company.
          value = @cheapest.min_bid
          @cheapest.discount += 5
          new_value = @cheapest.min_bid
          @log << "#{@cheapest.name} minimum bid decreases from "\
            "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"

          if new_value <= 0
            # It's now free so the current player is forced to take it.
            buy_company(@current_entity, @cheapest, 0)
            resolve_bids
            change_entity(nil)
          end
        else
          payout_companies
        end
        @entities.each(&:unpass!)
      end

      def pass_processed(_action)
        return unless @auctioning_company

        # Remove ourselves from the current bidding, but we can come back in.
        @bids[@auctioning_company]&.reject! do |bid|
          @current_entity.unpass!
          bid.entity == @current_entity
        end
        resolve_bids
      end

      def placement_bid(bid)
        if @companies.first == bid.company
          @auction_triggerer = bid.entity
          accept_bid(bid)
          resolve_bids
        else
          add_bid(bid)
        end
      end

      def resolve_bids
        while (bids = @bids[@companies.first])
          break if bids.empty?

          if bids.size == 1
            accept_bid(bids.first)
          else
            if @auctioning_company != @companies.first
              @auctioning_company = @companies.first
              @log << "#{@auctioning_company.name} goes up for auction"
            end
            break
          end
        end
      end

      def accept_bid(bid)
        price = bid.price
        company = bid.company
        player = bid.entity
        buy_company(player, company, price)
        @bids.delete(company)
        @auctioning_company = nil
      end

      def add_bid(bid)
        company = bid.company
        entity = bid.entity
        price = bid.price
        min = min_bid(company)
        raise Engine::GameError, "Minimum bid is #{min} #{@current_entity.name} #{company.name}" if bid.price < min
        raise GameError, 'Cannot afford bid' if bids_for_player(entity).sum(&:price) > entity.cash

        bids = @bids[company]
        bids.reject! { |b| b.entity == entity }
        bids << bid
        @bidders[company] |= [entity]

        @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name}"
      end

      def buy_company(player, company, price)
        company.owner = player
        player.companies << company
        player.spend(price, @bank) if price.positive?
        @companies.delete(company)
        @log <<
        case @bidders[company].size
        when 0
          "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
        when 1
          "#{player.name} wins the auction for #{company.name} "\
            "with the only bid of #{@game.format_currency(price)}"
        else
          "#{player.name} wins the auction for #{company.name} "\
            "with a bid of #{@game.format_currency(price)}"
        end

        return unless (ability = company.abilities(:share))

        share = ability[:share]
        if share.president
          @companies_pending_par << company
        else
          @share_pool.buy_share(player, share, exchange: :free)
        end
      end

      def bids_for_player(player)
        @bids.values.map do |bids|
          bids.find { |bid| bid.entity == player }
        end.compact
      end
    end
  end
end
