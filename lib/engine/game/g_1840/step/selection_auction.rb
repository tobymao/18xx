# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1840
      module Step
        class SelectionAuction < Engine::Step::Base
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
              all_passed! if entities.all?(&:passed?)
            end
            next_entity!
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

            entity == current_entity ? ACTIONS : []
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def setup
            setup_auction
            @companies = @game.companies.sort_by(&:value)
            @cheapest = @companies.first
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

          private

          def add_bid(bid)
            super(bid)
            company = bid.company
            entity = bid.entity
            price = bid.price

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
          end

          def win_bid(winner, _company)
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

          def forced_win(player, company)
            company.owner = player
            player.companies << company

            @companies.delete(company)
            @log << "#{player.name} wins the auction for #{company.name} "\
                    "for #{@game.format_currency(0)}"
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
                # It's now free so the next player is forced to take it.
                @round.next_entity_index!
                forced_win(current_entity, @cheapest)
                resolve_bids
              end
            else
              @game.payout_companies
              @game.or_set_finished
            end

            entities.each(&:unpass!)
          end

          def resolve_bids
            super
            entities.each(&:unpass!)
            @round.goto_entity!(@auction_triggerer)
          end
        end
      end
    end
  end
end
