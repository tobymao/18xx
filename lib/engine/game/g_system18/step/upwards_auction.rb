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
            @companies = @game.companies.reject(&:closed?).dup
            # setup_tiered_auction
          end

          def starting_bid(company)
            [0, company.value].max
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
            # Need to move entity round once more to be back to the priority deal player
            @round.next_entity_index!
            pass!
          end

          def resolve_bids
            super
            entities.each(&:unpass!)
            start_player = @auction_triggerer
            @round.goto_entity!(start_player)
            next_entity!
          end
        end
      end
    end
  end
end
