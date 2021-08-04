# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1866
      module Step
        class SelectionAuction < Engine::Step::Base
          include Engine::Step::PassableAuction

          ACTIONS = %w[bid pass].freeze

          attr_reader :companies

          def actions(entity)
            return [] if available.empty?

            entity == current_entity ? ACTIONS : []
          end

          def active_entities
            if @auctioning
              winning_bid = highest_bid(@auctioning)
              return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]] if winning_bid
            end

            super
          end

          def available
            @companies.reject { |c| c.id[0..1] == @game.class::STOCK_TURN_TOKEN_PREFIX }
          end

          def description
            'Initial Auction Round'
          end

          def may_purchase?(_company)
            false
          end

          def max_bid(player, _company)
            player.cash
          end

          def min_bid(company)
            return unless company

            return starting_bid(company) unless @bids[company].any?

            high_bid = highest_bid(company)
            (high_bid.price || company.min_bid) + min_increment
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def next_entity!
            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          def pass_description
            if auctioning
              "Pass (on #{auctioning.name})"
            else
              'Pass'
            end
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

          def process_bid(action)
            action.entity.unpass!

            if auctioning
              add_bid(action)
            else
              selection_bid(action)
              next_entity! if auctioning
            end
          end

          def setup
            setup_auction
            @companies = @game.companies.dup
          end

          def starting_bid(company)
            [0, company.value].max
          end

          private

          def add_bid(bid)
            super(bid)
            company = bid.company
            entity = bid.entity
            price = bid.price

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
          end

          def post_win_bid(winner, _company)
            entities.each(&:unpass!)
            @round.goto_entity!(winner.entity)
            next_entity!
          end

          def win_bid(winner, _company)
            player = winner.entity
            company = winner.company
            price = winner.price
            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            @companies.delete(company)
            @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"
          end

          def all_passed!
            available.each do |c|
              @game.companies.delete(c)
              @log << "#{c.name} is removed from the game"
            end
            @round.next_entity_index!
            pass!
          end
        end
      end
    end
  end
end
