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
            if entity.company? && !choices_ability(entity).empty? && @auctioning &&
              @bids[@auctioning].none? { |bid| bid.entity == entity.owner }
              return ['choose_ability']
            end

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
            privates_left = @companies
                              .map { |c| @game.class::COMPANY_SHORT_NAME[c.id] unless c.id == entity.id }
                              .compact
                              .sort
                              .join(', ')
            privates_left_str = "In alphabetical order, these are left for auction #{privates_left}."
            privates_left_str = 'Last one.' if privates_left.empty?
            @game.log << "#{entity.name} is up for auction. #{privates_left_str}"
            @auction_start_entity = entities[entity_index]
            auction_entity(entity)
          end

          def available
            return [] if @companies.empty?

            [@companies[0]]
          end

          def choices_ability(entity)
            return {} if !entity.company? || (entity.company? && !@game.stock_turn_token_company?(entity))

            choices = {}
            operator = entity.company? ? entity.owner : entity
            if @game.stock_turn_token?(operator)
              get_par_prices(operator).sort_by(&:price).each do |p|
                par_str = @game.par_price_str(p)
                choices[par_str] = par_str
              end
            end
            choices
          end

          def description
            'Initial Auction Round'
          end

          def get_par_prices(entity, corp = nil)
            par_type = @game.phase_par_type
            par_prices = @game.par_prices_sorted.select do |p|
              p.types.include?(par_type) && p.price <= entity.cash && @game.can_par_share_price?(p, corp)
            end
            par_prices.reject! { |p| p.price == @game.class::MAX_PAR_VALUE } if par_prices.size > 1
            par_prices
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

          def pass_entity(entity, silent = false)
            winning_bid = highest_bid(@auctioning)
            if silent
              remove_from_auction(entity)
            else
              pass_auction(entity)
            end
            return if winning_bid || @active_bidders.size == initial_auction_entities.size

            entity.pass!
            next_entity!
          end

          def process_choose_ability(action)
            entity = action.entity
            choice = action.choice
            share_price = nil
            get_par_prices(entity.owner).each do |p|
              next unless choice == @game.par_price_str(p)

              share_price = p
            end
            return unless share_price

            @game.purchase_stock_turn_token(entity.owner, share_price)
            @game.stock_turn_token_name!(entity)
            pass_entity(entity.owner, true)
          end

          def process_pass(action)
            pass_entity(action.entity)
          end

          def process_bid(action)
            add_bid(action)
          end

          def remove_company(company)
            @companies.delete(company)
            @log << if @game.class::NATIONAL_COMPANIES.include?(company.id)
                      "#{company.name} closes. It will form in phase 5"
                    elsif @game.class::MINOR_GERMANY_COMPANIES.include?(company.id)
                      "#{company.name} closes and is removed from the game. A share in Germany will be available "\
                        'when it forms'
                    elsif @game.class::MINOR_ITALY_COMPANIES.include?(company.id)
                      "#{company.name} closes and is removed from the game. A share in Italy will be available "\
                        'when it forms'
                    end
          end

          def setup
            setup_auction
            @companies = @game.companies.reject { |c| @game.stock_turn_token_company?(c) }

            auction_log(@companies[0]) unless @companies.empty?
          end

          def starting_bid(company)
            @game.class::COMPANY_STARTING_BID[company.id]
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

          def post_win_bid(_winner, _company)
            entities.each(&:unpass!)
            @round.goto_entity!(@auction_start_entity)
            next_entity!

            auction_log(@companies[0]) unless @companies.empty?
          end

          def win_bid(winner, company)
            if winner
              player = winner.entity
              company = winner.company
              price = winner.price
              if @game.class::NATIONAL_COMPANIES.include?(company.id)
                company.owner = player
                player.companies << company
              elsif @game.class::MINOR_COMPANIES.include?(company.id)
                minor_id = @game.class::MINOR_COMPANY_CORPORATION[company.id]
                minor = @game.corporation_by_id(minor_id)

                par_rows = @game.class::MINOR_NATIONAL_PAR_ROWS[minor_id]
                share_price = @game.stock_market.share_price(par_rows[0], par_rows[1])

                # Find the right spot on the stock market
                @game.stock_market.set_par(minor, share_price)

                # Select the president share to get
                share = minor.ipo_shares.first

                # Move all to the market
                bundle = ShareBundle.new(minor.shares_of(minor))
                @game.share_pool.transfer_shares(bundle, @game.share_pool)

                # Buy the share from the bank
                @game.share_pool.buy_shares(player,
                                            share.to_bundle,
                                            exchange: :free,
                                            exchange_price: share.price_per_share)
              end
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
