# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1871
      module Step
        class Auction < Engine::Step::Base
          include Engine::Step::Auctioner
          BID_ACTIONS = %w[bid pass].freeze
          OFFER_ACTIONS = %w[offer].freeze

          attr_reader :companies, :auctioning

          def description
            'Auction off Companies'
          end

          def finished?
            @companies.empty?
          end

          def pile_size
            entities.size == 3 ? 5 : 4
          end

          def setup
            setup_auction

            # Do not include King's Mail in the auction
            @companies = @game.companies.reject { |c| c.id == 'KM' }.sort_by { @game.rand }

            # For each player create their piles
            entities.each_with_index do |player, i|
              pile = @companies[(i * pile_size), pile_size]
              @log << "Offer pile for #{player.name}: #{pile.map(&:name).join(', ')}"
              pile.each do |company|
                player.unsold_companies << company
              end
            end
          end

          # The current available companies to show
          def available
            if @auctioning
              [@auctioning]
            else
              # Show the current players pile
              current_entity.unsold_companies
            end
          end

          def active_auction
            company = @auctioning
            bids = @bids[company]
            yield company, bids unless bids.empty?
          end

          def show_map
            true
          end

          def show_companies
            true
          end

          def process_offer(action)
            player = action.entity
            company = action.company

            # Make sure this company remains selected
            @selected_company = company

            # Setup our players
            @auctioneer = player
            @player1 = entities[(entity_index + 1) % entities.size]
            @player2 = entities[(entity_index + 2) % entities.size]
            @receiver = entities[(entity_index + 3) % entities.size]
            @auctioning = action.company

            # Reset passing state
            @player1.unpass!
            @player2.unpass!

            @log << "#{player.name} offers #{company.name}"
            goto_entity!(@player1)
          end

          def process_pass(action)
            player = action.entity
            @log << "#{player.name} passes on #{@auctioning.name}"
            player.pass!

            # Are there bids on the item?
            unless @bids[@auctioning].empty?
              win_item(highest_bid(@auctioning))
              return
            end

            # Have both players passed in a row?
            if @auctioning && @player1.passed? && @player2.passed?
              force_item(@auctioning)
              return
            end

            next_bidder!
          end

          def process_bid(action)
            add_bid(action)
            next_bidder!
          end

          def active?
            !@companies.empty?
          end

          def actions(entity)
            return [] if @companies.empty?

            actions = @auctioning ? BID_ACTIONS : OFFER_ACTIONS
            entity == current_entity ? actions : []
          end

          def round_state
            {
              companies_pending_par: [],
            }
          end

          def starting_bid(company)
            company.value + min_increment
          end

          def committed_cash(_player, _show_hidden)
            0
          end

          def min_bid(company)
            return unless company

            return starting_bid(company) if @bids[company].empty?

            highest_bid(company).price + min_increment
          end

          def may_purchase?(_company)
            false
          end

          def may_offer?(_company)
            !@auctioning
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

          def assign_item(player, company, price)
            # Make player buy company
            company.owner = player
            player.companies << company
            player.spend(price || company.value, @game.bank)

            # Remove company from unsold
            @auctioneer.unsold_companies.delete(company)
            @companies.delete(company)

            # Clear Bids
            @bids.delete(company)

            # Run any actions on this company being assigned
            @game.after_buy_company(player, company, price)
          end

          def win_item(bid)
            winner = bid.entity
            company = bid.company

            assign_item(winner, company, bid.price)
            @log << "#{winner.name} wins #{company.name} for $#{bid.price}"

            end_auction!
          end

          def force_on_highest_cash(company)
            # Get the highest cash total
            highest = entities.max_by(&:cash)

            # Pay privates until someone can win
            while highest.cash < company.value
              @log << "No player can afford #{company.name} ($#{company.value}), paying out companies"
              @game.payout_companies(ignore: ['KM'])

              highest = entities.max_by(&:cash)
            end

            # Now we have someone that can afford
            assign_item(highest, company, company.value)
            @log << "#{highest.name} is forced to buy #{company.name} for $#{company.value} - highest cash"
          end

          def force_item(company)
            # Check if the receiver can take the item
            if @receiver.cash >= company.value
              assign_item(@receiver, company, company.value)
              @log << "#{@receiver.name} is forced to buy #{company.name} for $#{company.value}"
            else
              force_on_highest_cash(company)
            end

            end_auction!
          end

          def next_bidder!
            if entity_index == entities.index(@player1)
              goto_entity!(@player2)
            else
              goto_entity!(@player1)
            end
          end

          def end_auction!
            goto_entity!(@player1)

            # Reset all of our variables
            @player1.unpass!
            @player2.unpass!
            @auctioneer = @auctioning = @player1 = @player2 = @receiver = nil
          end

          def goto_entity!(entity)
            @round.goto_entity!(entity)
          end
        end
      end
    end
  end
end
