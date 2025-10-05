# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G1817
      module Step
        class SelectionAuction < Engine::Step::Base
          include Engine::Step::PassableAuction
          ACTIONS = %w[bid pass].freeze
          ACTIONS_NO_PASS = %w[bid].freeze

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
            return ACTIONS_NO_PASS if @game.option_volatility_expansion? && !@auctioning

            ACTIONS
          end

          def min_increment
            @game.class::MIN_BID_INCREMENT
          end

          def setup
            setup_auction
            @companies = @game.companies.reject(&:closed?).dup
            setup_tiered_auction
            @seed_money = @game.option_volatility_expansion? ? nil : @game.class::SEED_MONEY
          end

          def setup_tiered_auction
            if @game.option_volatility_expansion?
              # Create Company Pyramid
              companies = @companies.dup
              companies.sort_by! { @game.rand }
              companies.delete(@game.pittsburgh_private)
              companies.unshift(@game.pittsburgh_private)
              @tiered_companies = 6.times.with_index.map { |i| companies.shift(i + 1) }
            else
              @tiered_companies = [@companies.dup]
            end
          end

          def tiered_auction_companies
            @tiered_companies
          end

          def may_bid?(company)
            return false if company == @game.empty_auction_slot
            return false unless @tiered_companies[-1].include?(company)

            super
          end

          def starting_bid(company)
            return 0 if @game.option_volatility_expansion?

            [0, company.value - @seed_money].max
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

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name},"\
                    " bank will provide #{@game.format_currency(seed_money_provided(company, price))}"
          end

          def seed_money_provided(company, price)
            [0, company.value - price].max
          end

          def win_bid(winner, _company)
            player = winner.entity
            @last_auction_winner = player
            company = winner.company
            price = winner.price
            company.owner = player
            player.companies << company
            seed = seed_money_provided(company, price)
            @seed_money -= seed if @seed_money && seed.positive?
            player.spend(price, @game.bank) if price.positive?
            @log <<
              if @seed_money && seed.positive?
                "#{player.name} wins the auction for #{company.name} "\
                  "with a bid of #{@game.format_currency(price)} spending"\
                  " #{@game.format_currency(seed)} seed money, #{@game.format_currency(@seed_money)} seed money remains"
              else
                "#{player.name} wins the auction for #{company.name} "\
                  "with a bid of #{@game.format_currency(price)}"
              end
            company_auction_finished(company)
          end

          def company_auction_finished(company)
            @companies.delete(company)
            return @tiered_companies[0].delete(company) unless @game.option_volatility_expansion?

            @tiered_companies.each do |row|
              next unless (index = row.index(company))

              row[index] = @game.empty_auction_slot
              remove_company_from_slot(row, index - 1) if company_in_slot?(row, index - 1) && !company_in_slot?(row, index - 2)
              remove_company_from_slot(row, index + 1) if company_in_slot?(row, index + 1) && !company_in_slot?(row, index + 2)
              @tiered_companies.delete(row) if row.all? { |c| c == @game.empty_auction_slot }
              break
            end
          end

          def company_in_slot?(row, index)
            !index.negative? && row[index] && row[index] != @game.empty_auction_slot
          end

          def remove_company_from_slot(row, index)
            company = row[index]
            company.close!
            @companies.delete(company)
            @log << "#{company.name} removed"
            row[index] = @game.empty_auction_slot
          end

          def all_passed!
            @companies.each(&:close!)
            # Need to move entity round once more to be back to the priority deal player
            @round.next_entity_index!
            pass!
          end

          def resolve_bids
            super
            entities.each(&:unpass!)
            start_player = @game.option_volatility_expansion? && @last_auction_winner ? @last_auction_winner : @auction_triggerer
            @round.goto_entity!(start_player)
            next_entity!
          end
        end
      end
    end
  end
end
