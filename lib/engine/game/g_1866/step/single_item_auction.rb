# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1866
      module Step
        class SingleItemAuction < Engine::Step::Base
          include Engine::Step::PassableAuction

          ACTIONS = %w[bid pass].freeze

          attr_reader :companies

          def actions(entity)
            return [] if available.empty?

            entity == current_entity ? ACTIONS : []
          end

          def active_auction
            company = @auctioning
            bids = @bids[company]
            yield company, bids
          end

          def active_entities
            if @auctioning
              winning_bid = highest_bid(@auctioning)
              return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]] if winning_bid
            end

            super
          end

          def auction_log(entity)
            privates_left = @companies.sort_by(&:name).map { |c| c.name unless c.id == entity.id }.compact.join(', ')
            privates_left_str = "In alphabetical order, these are left for auction #{privates_left}."
            privates_left_str = 'Last one.' if privates_left.empty?
            @game.log << "#{entity.name} is up for auction. #{privates_left_str}"
            auction_entity(entity)
          end

          def available
            return [] if @companies.empty?

            [@companies[0]]
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
            winning_bid = highest_bid(@auctioning)
            pass_auction(entity)
            return if winning_bid || @active_bidders.size == initial_auction_entities.size

            entity.pass!
            next_entity!
          end

          def process_bid(action)
            add_bid(action)
          end

          def remove_company(company)
            @companies.delete(company)
            @log << if @game.class::NATIONAL_COMPANIES.include?(company.id)
                      "#{company.name} closes. It will form in phase 5"
                    else
                      "#{company.name} closes and is removed from the game"
                    end
          end

          def setup
            setup_auction
            @companies = @game.companies.reject { |c| @game.stock_turn_token_company?(c) }

            auction_log(@companies[0]) unless @companies.empty?
          end

          def starting_bid(company)
            [0, company.value].max
          end

          private

          def add_bid(bid)
            company = bid.company
            entity = bid.entity
            price = bid.price
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"

            super
            resolve_bids
          end

          def post_win_bid(winner, _company)
            entities.each(&:unpass!)
            @round.goto_entity!(winner.entity) if winner
            next_entity!

            auction_log(@companies[0]) unless @companies.empty?
          end

          def win_bid(winner, company)
            if winner
              player = winner.entity
              company = winner.company
              price = winner.price
              company.owner = player
              player.companies << company
              player.spend(price, @game.bank) if price.positive?
              @companies.delete(company)
              @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"
            else
              remove_company(company)
            end
          end
        end
      end
    end
  end
end
