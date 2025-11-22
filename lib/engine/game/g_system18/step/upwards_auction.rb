# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module GSystem18
      module Step
        class UpwardsAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          ACTIONS = %w[bid pass].freeze
          PRICE_DROP = 5

          attr_reader :companies

          def description
            'Bid on Companies'
          end

          def available
            @companies
          end

          def active_entities
            if @auctioning
              winning_bid = highest_bid(@auctioning)
              return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]] if winning_bid
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
              return next_entity! unless entities.all?(&:passed?)

              all_passed!
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
              next_entity! if auctioning
            end
          end

          def actions(entity)
            return [] if @companies.empty?
            return [] unless entity == current_entity

            ACTIONS
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def setup
            setup_auction
            @companies = @game.companies.reject(&:closed?).sort_by(&:value)
          end

          def starting_bid(company)
            [0, company.min_bid].max
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

          private

          def add_bid(bid)
            super(bid)
            entity = bid.entity
            price = bid.price

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name}"
          end

          def win_bid(winner, _company)
            player = winner.entity
            @last_auction_winner = player
            company = winner.company
            price = winner.price
            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            @log << "#{player.name} wins the auction for #{company.name} "\
                    "with a bid of #{@game.format_currency(price)}"
            company_auction_finished(company)
          end

          def company_auction_finished(company)
            @companies.delete(company)
          end

          def all_passed!
            if @companies.empty?
              # Need to move entity round once more to be back to the priority deal player
              pass!
              return
            end

            all_pass_next_entity

            discount_company
          end

          def all_pass_next_entity
            @round.next_entity_index!
          end

          def discount_company
            # if any privates still left, reduce price and start over
            company = @companies.first
            company.discount += PRICE_DROP
            if @companies.first.min_bid <= 0
              company.discount = company.value
              player = @round.current_entity
              company.owner = player
              player.companies << company
              @log << "#{player.name} receives #{company.name} for #{@game.format_currency(0)}"
              company_auction_finished(company)
              post_win_order(player)
              pass! if @companies.empty?
            else
              @log << "#{company.name} price reduced to #{@game.format_currency(company.min_bid)}"
              post_price_reduction(company)
            end
          end

          def post_price_reduction(_company)
            entities.each(&:unpass!)
          end

          def post_win_bid(winner, _company)
            post_win_order(winner.entity)
          end

          def post_win_order(winning_player)
            entities.each(&:unpass!)

            # start with player after the winner
            @round.last_to_act = winning_player
            @round.goto_entity!(winning_player)
            next_entity!
          end
        end
      end
    end
  end
end
