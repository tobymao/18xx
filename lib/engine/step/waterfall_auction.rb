# frozen_string_literal: true

require_relative 'base'
require_relative 'auctioner'

module Engine
  module Step
    class WaterfallAuction < Base
      include Auctioner
      ACTIONS = %w[bid pass].freeze

      attr_reader :companies

      def description
        'Bid on Companies'
      end

      def available
        @companies
      end

      def process_pass(action)
        entity = action.entity

        if auctioning
          pass_auction(action.entity)
        else
          @log << "#{entity.name} passes bidding"
          entity.pass!
          all_passed! if entities.all?(&:passed?)
          @round.next_entity_index!
        end
      end

      def process_bid(action)
        action.entity.unpass!

        if auctioning
          add_bid(action)
        else
          @round.last_to_act = action.entity
          placement_bid(action)
          @round.next_entity_index!
        end
      end

      def active_entities
        active_auction do |_, bids|
          return [bids.min_by(&:price).entity]
        end

        super
      end

      def actions(entity)
        return [] if @companies.empty?

        correct = false

        active_auction do |_company, bids|
          correct = bids.min_by(&:price).entity == entity
        end

        correct || entity == current_entity ? ACTIONS : []
      end

      def setup
        setup_auction
        @companies = @game.companies.sort_by(&:value)
        @cheapest = @companies.first
        @bidders = Hash.new { |h, k| h[k] = [] }
      end

      def round_state
        {
          companies_pending_par: [],
        }
      end

      def min_bid(company)
        return unless company
        return company.min_bid if may_purchase?(company)

        high_bid = highest_bid(company)
        (high_bid ? high_bid.price : company.min_bid) + min_increment
      end

      def may_purchase?(company)
        active_auction { return false }
        company && company == @companies.first
      end

      def committed_cash(player, _show_hidden = false)
        bids_for_player(player).sum(&:price)
      end

      def max_bid(player, company)
        player.cash - committed_cash(player) + current_bid_amount(player, company)
      end

      protected

      def resolve_bids
        until (company = @companies.first).nil?
          break unless resolve_bids_for_company(company)
        end
      end

      def resolve_bids_for_company(company)
        resolved = false
        @auctioning = nil
        bids = @bids[company]

        if bids.one?
          accept_bid(bids.first)
          resolved = true
        elsif can_auction?(company)
          @auctioning = company
          @log << "#{@auctioning.name} goes up for auction"
        end

        resolved
      end

      def active_auction
        company = @auctioning
        bids = @bids[company]
        yield company, bids if bids.size > 1
      end

      def can_auction?(company)
        company == @companies.first && @bids[company].size > 1
      end

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

      def placement_bid(bid)
        if may_purchase?(bid.company)
          @auction_triggerer = bid.entity
          accept_bid(bid)
          resolve_bids
        else
          add_bid(bid)
        end
      end

      def buy_company(player, company, price)
        if (available = max_bid(player, company)) < price
          @game.game_error("#{player.name} has #{@game.format_currency(available)} "\
                           'available and cannot spend '\
                           "#{@game.format_currency(price)}")
        end

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

        company.abilities(:shares) do |ability|
          ability.shares.each do |share|
            if share.president
              @round.companies_pending_par << company
            else
              @game.share_pool.buy_shares(player, share, exchange: :free)
            end
          end
        end
      end

      private

      def accept_bid(bid)
        price = bid.price
        company = bid.company
        player = bid.entity
        @bids.delete(company)
        buy_company(player, company, price)
      end

      def add_bid(bid)
        super
        company = bid.company
        price = bid.price
        entity = bid.entity

        @bidders[company] |= [entity]

        @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name}"
      end
    end
  end
end
