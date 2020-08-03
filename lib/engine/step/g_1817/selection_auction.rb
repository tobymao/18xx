# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1817
      class SelectionAuction < Base
        include Auctioner
        ACTIONS = %w[bid pass].freeze

        attr_reader :bids, :companies

        def description
          'Bid on Companies'
        end

        def available
          @companies
        end

        def process_pass(action)
          entity = action.entity

          if auctioning_company
            entity.pass!
            pass_auction(action)

          else
            @log << "#{entity.name} passes bidding"
            entity.pass!
            all_passed! if entities.all?(&:passed?)
          end

          next_entity!
        end

        def next_entity!
          return if entities.all?(&:passed?)

          @round.next_entity_index!
          next_entity! if entities[entity_index]&.passed?
        end

        def process_bid(action)
          action.entity.unpass!

          if auctioning_company
            add_bid(action)
          else
            selection_bid(action)
          end
          next_entity!
        end

        def actions(entity)
          return [] if @companies.empty?

          entity == current_entity ? ACTIONS : []
        end

        def min_increment
          @game.class::MIN_BID_INCREMENT
        end

        def setup
          super
          @companies = @game.companies.sort_by(&:min_bid)
          @auctioning = nil
          @seed_money = @game.class::SEED_MONEY
        end

        def starting_bid(company)
          [0, company.value - @seed_money].max
        end

        def min_bid(company)
          return unless company

          return starting_bid(company) unless @bids[company].any?

          high_bid = highest_bid(company)
          (high_bid.price || company.min_bid) + min_increment
        end

        def may_purchase?(_company)
          false
        end

        def committed_cash(_player, _show_hidden = false)
          0
        end

        def max_bid(player, _company)
          player.cash
        end

        private

        def active_company_bids
          company = @auctioning
          bids = @bids[company]
          yield company, bids if bids.any?
        end

        def selection_bid(bid)
          add_bid(bid)
          entities.each(&:unpass!)
          @auctioning = bid.company
          @auction_triggerer = bid.entity
        end

        def resolve_bids
          return unless entities.one? { |e| !e.passed? }

          winner = @bids[@auctioning].first
          win_bid(winner.entity, winner.company, winner.price)
          @bids.clear
          @auctioning = nil
          entities.each(&:unpass!)
          @round.goto_entity!(@auction_triggerer)
        end

        def add_bid(bid)
          super(bid)
          company = bid.company
          entity = bid.entity
          price = bid.price

          @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name},"\
          " bank will provide #{@game.format_currency(seed_money_provided(company, price))}"
        end

        def seed_money_provided(company, price)
          [0, company.value - price].max
        end

        def win_bid(player, company, price)
          company.owner = player
          player.companies << company
          seed = seed_money_provided(company, price)
          if seed.positive?
            @game.bank.cash -= seed
            @seed_money -= seed
          end
          player.spend(price, @game.bank) if price.positive?
          @companies.delete(company)
          @log <<
            if seed.positive?
              "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)} spending"\
                " #{@game.format_currency(seed)} seed money, #{@game.format_currency(@seed_money)} seed money remains"
            else
              "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)}"
            end
        end

        def all_passed!
          @companies.each { |c| @game.companies.delete(c) }
          # Need to move entity round once more to be back to the priority deal player
          @round.next_entity_index!
          pass!
        end
      end
    end
  end
end
