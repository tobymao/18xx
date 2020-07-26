# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class WaterfallAuction < Base
      ACTIONS = %w[bid pass].freeze

      attr_reader :bids, :companies

      def description
        'Bid on Companies'
      end

      def pass_description
        if auctioning_company
          "Pass (on #{auctioning_company.sym})"
        else
          'Pass'
        end
      end

      def process_pass(action)
        entity = action.entity

        if auctioning_company
          @log << "#{entity.name} passes on #{auctioning_company.name}"

          # Remove ourselves from the current bidding, but we can come back in.
          @bids[auctioning_company]&.reject! do |bid|
            bid.entity == entity
          end
          resolve_bids
        else
          @log << "#{entity.name} passes bidding"
          entity.pass!
          all_passed! if entities.all?(&:passed?)
          @round.next_entity_index!
        end
      end

      def process_bid(action)
        action.entity.unpass!

        if auctioning_company
          add_bid(action)
        else
          placement_bid(action)
          @round.next_entity_index!
        end
      end

      def active_entities
        active_company_bids do |_, bids|
          return [bids.min_by(&:price).entity]
        end

        super
      end

      def actions(entity)
        return [] if @companies.empty?

        correct = false

        active_company_bids do |_company, bids|
          correct = bids.min_by(&:price).entity == entity
        end

        correct || entity == current_entity ? ACTIONS : []
      end

      def min_increment
        @game.class::MIN_BID_INCREMENT
      end

      def setup
        @companies = @game.companies.sort_by(&:min_bid)
        @cheapest = @companies.first
        @bids = Hash.new { |h, k| h[k] = [] }
        @bidders = Hash.new { |h, k| h[k] = [] }
      end

      def round_state
        {
          company_pending_par: nil,
        }
      end

      def min_bid(company)
        return unless company
        return company.min_bid if may_purchase?(company)

        high_bid = @bids[company].max_by(&:price)
        (high_bid ? high_bid.price : company.min_bid) + min_increment
      end

      def may_purchase?(company)
        active_company_bids { return false }
        company && company == @companies.first
      end

      def committed_cash(player)
        bids_for_player(player).sum(&:price)
      end

      def current_bid_amount(player, company)
        bids[company]&.find { |b| b.entity == player }&.price || 0
      end

      def max_bid(player, company)
        player.cash - committed_cash(player) + current_bid_amount(player, company)
      end

      private

      def all_passed!
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
            buy_company(current_entity, @cheapest, 0)
            resolve_bids
          end
        else
          @game.payout_companies
          @game.or_set_finished
        end

        entities.each(&:unpass!)
      end

      def active_company_bids
        company = @companies[0]
        bids = @bids[company]
        yield company, bids if bids.any?
      end

      def auctioning_company
        active_company_bids { |company, _| company }
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
          break @log << "#{auctioning_company.name} goes up for auction" unless bids.one?

          accept_bid(bids.first)
        end
      end

      def accept_bid(bid)
        price = bid.price
        company = bid.company
        player = bid.entity
        buy_company(player, company, price)
        @bids.delete(company)
      end

      def add_bid(bid)
        company = bid.company
        entity = bid.entity
        price = bid.price
        min = min_bid(company)
        raise Engine::GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if price < min
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
        player.spend(price, @game.bank) if price.positive?
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

        company.abilities(:share) do |ability|
          share = ability.share

          if share.president
            @round.company_pending_par = company
          else
            @game.share_pool.buy_shares(player, share, exchange: :free)
          end
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
