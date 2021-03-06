# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18NEB
      module Step
        class PriceFindingAuction < Engine::Step::Base
          include Engine::Step::Auctioner

          attr_reader :companies
          attr_reader :bids

          # On your turn, must bid on a private or pass
          # if any privates are left and everyone passes in a row, privates with a bid
          #     are purchased, privates without a bid are reduced by standard deduction
          # if everyone passes and all items have a bid, the auction ends.

          ACTIONS = %w[bid pass].freeze

          STANDARD_DEDUCTION = 10

          # TODO: grab min prices from companies
          MIN_PRICES = {
            'P1' => 20,
            'P2' => 40,
            'P3' => 70,
            'P4' => 100,
            'P5' => 130,
            'P6' => 175,
          }.freeze

          def description
            'Price Finding Auction on Private Companies'
          end

          def available
            @companies
          end

          def auctioneer?
            false
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def pass_description
            'Pass'
          end

          def process_bid(action)
            # replace the current bid on company, if any, with this bid.
            entity = action.entity
            replace_bid(action)
            entity.unpass!
            @round.next_entity_index!
          end

          def process_pass(action)
            entity = action.entity
            @log << "#{entity.name} passes"
            entity.pass!
            all_passed! if entities.all?(&:passed?)
            @round.next_entity_index!
          end

          def actions(entity)
            return [] if @companies.empty? || !entity.player? || (entity != current_entity)

            ACTIONS
          end

          def setup
            setup_auction
            @companies = @game.companies.sort_by(&:min_bid)
            @bidders = Hash.new { |h, k| h[k] = [] }
            @log << "started Price Finding Auction"
          end

          def min_bid(company) return unless company
            return unless company

            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : company.value - company.discount
          end

          def auctioning
            nil
          end

          # can never purchase directly
          def may_purchase?(_company)
            false
          end

          def discount_company(company)
            company.discount += STANDARD_DEDUCTION
            price = company.value - company.discount
            @log << "#{company.name} min price reduced " +
                     "by #{@game.format_currency(STANDARD_DEDUCTION)} " +
                     "to #{@game.format_currency(price)}"
          end

          protected

          def active_auction
            false
          end

          def all_passed!
            # 1. Resolve Bids: companies with bids are purchased AND removed from auction
            # 2. Discount companies without bids
            # 3. Unpass all players
            # 2. End auction if companies have all been purchased.
            resolve_bids
            discount_companies
            entities.each(&:unpass!)
            @round.next_entity_index!
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
            buy_company(high_bid.entity, company, high_bid.price)
          end

          def buy_company(player, company, price)
            company.owner = player
            player.companies << company
            # P1 can be reduced to free, so we disable `check_positive` in that case
            player.spend(price, @game.bank, check_positive: company.sym != 'P1')
            @companies.delete(company)
            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            @game.abilities(company, :share) do |ability|
              share = ability.share

              if share.president
                # TODO: - I think this isn't necessary since we must par CAR to 100
                @round.company_pending_par = company
              else
                @game.share_pool.buy_shares(player, share, exchange: :free)
              end
            end
          end

          def discount_companies
            @companies.each {|company| discount_company(company) }
          end

          # Only one person may bid at a time 
          def replace_bid(bid)
            check_bid(bid)
            company = bid.company
            price = bid.price
            entity = bid.entity

            bids = @bids[company]
            bids.reject! { |b| b.entity == entity }
            bids.reject! { |b| b.entity != entity }
            bids << bid

            #@bidders[company] = [entity]

            @log << "#{entity.name} is bidder #{@game.format_currency(price)} on #{bid.company.name}"
          end

          def check_bid(bid)
            company = bid_target(bid)
            entity = bid.entity
            price = bid.price
            min = min_bid(company)
            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if price < min
            if @game.class::MUST_BID_INCREMENT_MULTIPLE && ((price - min) % @game.class::MIN_BID_INCREMENT).nonzero?
              raise GameError, "Must increase bid by a multiple of #{@game.class::MIN_BID_INCREMENT}"
            end
            if price > max_bid(entity, company)
              raise GameError, "Cannot afford bid. Maximum possible bid is #{max_bid(entity, company)}"
            end
          end

          def max_bid(player, company)
            player.cash - committed_cash(player) + current_bid_amount(player, company)
          end

          def accept_bid(bid)
            price = bid.price
            company = bid.company
            player = bid.entity
            @bids.delete(company)
            buy_company(player, company, price)
          end
        end
      end
    end
  end
end
