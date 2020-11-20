# frozen_string_literal: true

require_relative '../base'
require_relative '../passable_auction'

module Engine
  module Step
    module G1867
      class SingleItemAuction < Base
        # Auction which puts up the lowest price item,
        # if nobody buys switches to a dutch auction until a player purchases
        include PassableAuction
        ACTIONS = %w[bid pass].freeze

        def actions(entity)
          return [] if @companies.empty?

          entity == current_entity ? ACTIONS : []
        end

        attr_reader :companies

        def description
          'Bid on Companies'
        end

        def available
          @companies
        end

        def active_auction
          company = @auctioning
          bids = @bids[company]
          yield company, bids
        end

        def initial_auction_entities
          entities.rotate(@round.entity_index)
        end

        def active_entities
          winning_bid = highest_bid(@auctioning)
          if winning_bid
            [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]]
          else
            [@active_bidders.first]
          end
        end

        def process_pass(action)
          entity = action.entity

          pass_auction(entity)
          resolve_bids
        end

        def process_bid(action)
          add_bid(action)
        end

        def min_increment
          @game.class::MIN_BID_INCREMENT
        end

        def setup
          setup_auction
          @companies = @game.companies.sort_by(&:value)

          auction_entity_log(@companies.first)
        end

        def starting_bid(company)
          company.min_bid
        end

        def auction_entity_log(entity)
          @dutch_mode = false
          @game.log << "#{entity.name} is up for auction, minimum bid is #{@game.format_currency(min_bid(entity))}"
          auction_entity(entity)
        end

        def min_bid(company)
          return unless company

          return company.min_bid if @dutch_mode

          return starting_bid(company) unless @bids[company].any?

          high_bid = highest_bid(company)
          (high_bid.price || company.min_bid) + min_increment
        end

        def may_purchase?(_company)
          @dutch_mode
        end

        def max_bid(player, _company)
          player.cash
        end

        private

        def add_bid(bid)
          entity = bid.entity
          price = bid.price

          if @dutch_mode
            @active_bidders.select! { |e| e == bid.entity }
          else
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name}"
          end
          super
          resolve_bids
        end

        def win_bid(winner, company)
          unless winner
            # Switch to dutch auction
            tense = @dutch_mode ? 'bought' : 'bid on'
            company.discount += 5
            @log << "Nobody #{tense} #{company.name}, reducing price to #{@game.format_currency(company.min_bid)}"
            @dutch_mode = true

            return
          end
          player = winner.entity
          company = winner.company
          price = winner.price
          company.owner = player
          player.companies << company

          player.spend(price, @game.bank) if price.positive?
          @companies.delete(company)
          @log << "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)}"
        end

        def post_win_bid(winner, company)
          if winner
            @round.goto_entity!(winner.entity)
            @round.next_entity_index!
            if @companies.any?
              auction_entity_log(@companies.first)
            else
              pass!
            end
          else
            auction_entity(company)
            if company.min_bid.zero?
              # Fake the first player making a bid
              bid = Engine::Action::Bid.new(@active_bidders.first, company: company, price: company.min_bid)
              add_bid(bid)
            end
            resolve_bids
          end
        end

        def all_passed!
          @companies.each { |c| @game.companies.delete(c) }
          # Need to move entity round once more to be back to the priority deal player
          pass!
        end
      end
    end
  end
end
