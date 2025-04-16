# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class SelectionAuction < Base
      include Engine::Step::PassableAuction
      ACTIONS = %w[bid pass].freeze

      attr_reader :companies

      def description
        'Bid on Companies'
      end

      def available
        @companies
      end

      def may_bid?(company)
        return false unless @companies.first == company

        super
      end

      def initial_auction_entities
        entities.rotate(@round.entity_index)
      end

      def active_entities
        return super unless auctioning

        if (winning_bid = highest_bid(@auctioning))
          return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]]
        end

        [@active_bidders[0]]
      end

      def process_pass(action)
        entity = action.entity

        if auctioning
          pass_auction(entity)
          resolve_bids
        else
          @log << "#{entity.name} passes bidding"
          @active_bidders.delete(entity)
          entity.pass!
          all_passed! if entities.all?(&:passed?)
          next_entity! unless @all_passed_win
          @all_passed_win = false
        end
      end

      def next_entity!
        @round.next_entity_index!
        entity = entities[entity_index]
        if @auctioning
          entity.pass! if max_bid(entity, @auctioning) < min_bid(@auctioning)
        elsif @companies.none? { |c| max_bid(entity, c) >= min_bid(c) }
          @log << "#{entity.name} has no valid actions and passes"
          entity.pass!
          entity = nil if entities.all?(&:passed?)
        end
        next_entity! if entity&.passed?
      end

      def process_bid(action)
        action.entity.unpass!

        if !auctioning
          selection_bid(action)
          next_entity! if auctioning
        elsif @active_bidders.length == 1
          add_bid(action)
          resolve_bids
        else
          auctioning
          add_bid(action)
        end
      end

      def actions(entity)
        return [] if @companies.empty?

        entity == current_entity ? ACTIONS : []
      end

      def min_increment
        @game.class::MIN_BID_INCREMENT
      end

      def setup
        setup_auction
        @companies = @game.initial_auction_companies.dup
        @cheapest = @companies.first
        auction_entity(initial_auction_entity) if initial_auction_entity
        @auction_triggerer = current_entity
      end

      def starting_bid(company)
        company.min_bid
      end

      def min_bid(company)
        return unless company

        return starting_bid(company) if @bids[company].empty?

        high_bid = highest_bid(company)
        (high_bid.price || company.min_bid) + min_increment
      end

      def may_purchase?(_company)
        false
      end

      def max_bid(player, _company)
        player.cash
      end

      protected

      def active_auction
        company = @auctioning
        bids = @bids[company]
        yield company, bids if company
      end

      def initial_auction_entity
        @companies.first
      end

      def resolve_bids
        if @auctioning && @active_bidders.none? && @bids[auctioning].empty?
          all_passed!
        else
          super
        end
      end

      private

      def add_bid(bid)
        super
        company = bid.company
        entity = bid.entity
        price = bid.price

        @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
      end

      def win_bid(winner, _company)
        player = winner.entity
        company = winner.company
        price = winner.price
        assign_company(company, player)

        @log << "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)}"
        player.spend(price, @game.bank) if price.positive?
        @game.after_buy_company(player, company, price)
        @companies.delete(company)
      end

      def forced_win(player, company)
        @active_bidders = [player]
        process_bid(Engine::Action::Bid.new(player, price: 0, company: company))
      end

      def assign_company(company, player)
        company.owner = player
        player.companies << company
      end

      def all_passed!
        # Everyone has passed so we need to run a fake OR.
        if @companies.include?(@cheapest)
          # Decrease cheapest by 5
          value = @cheapest.min_bid
          @cheapest.discount += 5
          new_value = @cheapest.min_bid
          @log << "#{@cheapest.name} minimum bid decreases from "\
                  "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"
          auction_entity(@cheapest)
          if new_value <= 0
            # It's now free so the next player is forced to take it.
            @round.next_entity_index!
            forced_win(current_entity, @cheapest)
          end
        else
          @game.payout_companies
          @game.or_set_finished
          auction_entity(@companies.first)
        end

        entities.each(&:unpass!)
      end

      def post_win_bid(_winner, _company)
        @round.goto_entity!(@auction_triggerer)
        entities.each(&:unpass!)
        next_entity!
        @auction_triggerer = current_entity
        auction_entity(@companies.first) unless @companies.empty?
      end
    end
  end
end
