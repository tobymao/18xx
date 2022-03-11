# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18Dixie
      module Step
        class SelectionAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          INITIAL_AUCTION_PRIVATE_SYMS = %w[P1 P2 P3 P4 P5 P6 P7].freeze

          attr_reader :companies

          def description
            'Initial Private Auction'
          end

          def available
            @companies
          end

          def active_entities
            if @auctioning
              winning_bid = highest_bid(@auctioning)
              return [@active_bidders[(@active_bidders.index(winning_bid.entity) + 1) % @active_bidders.size]] if winning_bid
            end
            super # .select { |player| player.companies.empty? }
          end

          def process_pass(action)
            entity = action.entity
            raise GameError "#{entity.name} cannot pass now" unless auctioning

            pass_auction(entity)
            resolve_bids
          end

          def initial_auction_entities
            entities.select { |player| player.companies.empty? }
          end

          def starting_bid(company)
            company.value
          end

          def next_entity!(auction_triggerer)
            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity!(auction_triggerer) if entity != auction_triggerer && (entity&.passed || !entity.companies.empty?)
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
            return [] if entity != current_entity || !entity.companies.empty? # || entity.passed?
            return %w[bid pass].freeze if @auctioning

            %w[bid].freeze
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def setup
            setup_auction
            @companies = @game.companies.select { |c| INITIAL_AUCTION_PRIVATE_SYMS.include?(c.sym) }
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
            company = winner.company
            price = winner.price
            company.owner = player
            player.companies << company

            player.spend(price, @game.bank)
            @companies.delete(company)
            @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"
          end

          def resolve_bids
            super
            entities.each(&:unpass!)
            @round.goto_entity!(@auction_triggerer)
            if initial_auction_entities.empty?
              finish_auction
            else
              next_entity!(@auction_triggerer)
            end
          end

          def finish_auction
            most_valuable_unsold_company = @companies.pop
            most_valuable_unsold_company.close!
            @game.log << "#{most_valuable_unsold_company.name} is removed from the game"
            @companies.reverse_each { |c| @game.put_private_in_pool(c) }
          end
        end
      end
    end
  end
end
