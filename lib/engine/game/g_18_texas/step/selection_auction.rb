# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18Texas
      module Step
        class SelectionAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          ACTIONS = %w[bid pass].freeze
          ACTIONS_WITH_PASS = %w[bid assign pass].freeze


          attr_reader :companies

          def description
            'Bid on Companies'
          end

          def available
            @companies
          end

          def process_pass(_action)
            return all_passed! if entities.all?(&:passed?)

            next_entity!
          end

          def next_entity!
            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          def process_bid(action)
            action.entity.unpass!

            selection_bid(action)
          end

          def selection_bid(bid)
            add_bid(bid)
            next_entity!
          end

          def auctioneer?
            false
          end

          def actions(entity)
            return [] if @companies.empty? || !entity.player? || (entity != current_entity)

            entity.player.companies.empty? ? ACTIONS : ACTIONS_WITH_PASS
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def setup
            setup_auction
            @companies = @game.companies.dup
          end

          def starting_bid(company)
            [0, company.value].max
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

          def win_bid(winner, _company)
            player = winner.entity
            company = winner.company
            price = winner.price
            company.owner = player
            player.companies << company

            player.spend(price, @game.bank) if price.positive?
            @companies.delete(company)
            @log <<
                "#{player.name} wins the auction for #{company.name} "\
                "with a bid of #{@game.format_currency(price)}"
          end

          def all_passed!
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
end
