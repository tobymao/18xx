# frozen_string_literal: true

require_relative '../base'
require_relative '../passable_auction'

module Engine
  module Step
    module G1817
      class SelectionAuction < Base
        include PassableAuction
        ACTIONS = %w[bid pass].freeze

        attr_reader :companies, :seed_money

        def description
          'Bid on Companies'
        end

        def available
          @companies
        end

        def active_entities
          if @auctioning
            winning_bid = highest_bid(@auctioning)
            if winning_bid
              return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]]
            end
          end

          super
        end

        def process_pass(action)
          entity = action.entity

          if auctioning
            pass_auction(entity)
            resolve_bids
          else
            @log << "#{entity.name} passes bidding"
            entity.pass!
            return all_passed! if entities.all?(&:passed?)

            next_entity!
          end
        end

        def next_entity!
          @round.next_entity_index!
          entity = entities[entity_index]
          next_entity! if entity&.passed?
        end

        def process_bid(action)
          action.entity.unpass!

          if auctioning
            add_bid(action)
          else
            selection_bid(action)
            next_entity!
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
          @companies = @game.companies.dup
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

        def max_bid(player, _company)
          player.cash
        end

        private

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

        def win_bid(winner, _company)
          player = winner.entity
          company = winner.company
          price = winner.price
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

        def resolve_bids
          super
          entities.each(&:unpass!)
          @round.goto_entity!(@auction_triggerer)
          next_entity!
        end
      end
    end
  end
end
