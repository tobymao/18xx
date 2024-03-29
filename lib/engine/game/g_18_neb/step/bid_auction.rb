# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18Neb
      module Step
        class BidAuction < Engine::Step::Base
          include Engine::Step::Auctioner

          attr_reader :companies

          ACTIONS = %w[bid pass].freeze

          ALL_PASS_PRICE_DISCOUNT = 10

          def description
            'Bid on Companies'
          end

          def available
            @companies
          end

          def available_cash(player)
            player.cash - committed_cash(player)
          end

          def committed_cash(player, _show_hidden = false)
            player_bids = bids_for_player(player)
            return 0 if player_bids.empty?

            player_bids.sum(&:price)
          end

          def pass_description
            'Pass'
          end

          def process_bid(action)
            entity = action.entity
            entity.unpass!
            add_bid(action)
            @log << "#{entity.name} bids #{@game.format_currency(action.price)} on #{action.company.name}"
            @round.next_entity_index!
          end

          def process_pass(action)
            entity = action.entity
            @log << "#{entity.name} passes bidding"
            entity.pass!
            all_passed! if entities.all?(&:passed?)
            @round.next_entity_index!
          end

          def actions(entity)
            return [] if @companies.empty? || entity != current_entity

            ACTIONS
          end

          def round_state
            {
              companies_pending_par: [],
            }
          end

          def setup
            setup_auction
            @companies = @game.companies.dup.sort_by(&:min_bid)
          end

          def min_bid(company)
            return unless company

            high_bid = highest_bid(company)
            high_bid ? (high_bid.price + min_increment) : company.min_bid
          end

          # can never purchase directly
          def may_purchase?(_company)
            false
          end

          def active_auction; end

          def all_passed!
            resolve_bids
            discount_companies
            entities.each(&:unpass!)
            reset_bids
            @round.next_entity_index!
            process_forced_wins
          end

          def resolve_bids
            # company is deleted from @companies when they are won, so we can't loop
            # through @companies instead of @bids.
            @bids.each do |company, bids|
              resolve_bids_for_company(company, bids)
            end
          end

          def resolve_bids_for_company(company, bids)
            return if bids.empty?

            high_bid = highest_bid(company)
            win_bid(high_bid.entity, company, high_bid.price) if high_bid
          end

          def discount_companies
            @companies.each { |company| discount_company(company) }
          end

          def discount_company(company)
            discount = [company.min_bid, ALL_PASS_PRICE_DISCOUNT].min
            company.discount += discount

            @log << "#{company.name} price reduced " \
                    "by #{@game.format_currency(discount)} " \
                    "to #{@game.format_currency(company.min_bid)}"
          end

          def win_bid(player, company, price)
            assign_company(company, player)
            player.spend(price, @game.bank) if price.positive?
            @game.after_buy_company(player, company, price)

            @companies.delete(company)
            @log << if price.positive?
                      "#{player.name} wins the auction for #{company.name} "\
                        "with a bid of #{@game.format_currency(price)}"
                    else
                      "#{company.name}'s price has reached #{@game.format_currency(0)}. "\
                        "#{player.name} acquires #{company.name} for free."
                    end
          end

          def assign_company(company, player)
            company.owner = player
            player.companies << company
          end

          def process_forced_wins
            @companies.dup.each do |company|
              win_bid(current_entity, company, 0) if company.min_bid.zero?
            end
          end

          def max_bid(player, company)
            player.cash - committed_cash(player) + current_bid_amount(player, company)
          end
        end
      end
    end
  end
end
