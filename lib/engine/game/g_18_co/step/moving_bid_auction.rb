# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/auctioner'

module Engine
  module Game
    module G18CO
      module Step
        class MovingBidAuction < Engine::Step::Base
          include Engine::Step::Auctioner
          ACTIONS = %w[bid move_bid pass].freeze

          attr_reader :companies

          def description
            'Moving Bid Auction for Companies'
          end

          def active?
            !all_passed?
          end

          def all_passed?
            entities.all?(&:passed?)
          end

          def available
            @companies
          end

          def skip!
            entity = @round.entities[@round.entity_index]
            return unless entity.player?
            return if entity.cash > committed_cash(entity)

            entity.pass!
            log_skip(entity)
            @round.pass_order |= [current_entity]
            end_auction! if all_passed?
            @round.next_entity_index!
            skip! if active?
          end

          def log_skip(entity)
            @log << "#{entity.name} skips bidding as all their cash is committed"
          end

          def process_pass(action)
            entity = action.entity
            @log << "#{entity.name} passes bidding"
            entity.pass!
            @round.pass_order |= [current_entity]
            end_auction! if all_passed?
            @round.next_entity_index!
          end

          def process_bid(action)
            add_bid(action)
            action.entity.unpass!
            @round.pass_order.delete(current_entity)
            @round.next_entity_index!
          end

          def process_move_bid(action)
            move_bid(action)
            action.entity.unpass!
            @round.pass_order.delete(current_entity)
            @round.next_entity_index!
          end

          def actions(entity)
            return [] unless active?
            return [] unless entity.player?
            return [] if entity.cash <= committed_cash(entity)

            ACTIONS
          end

          def setup
            setup_auction
            @companies = @game.companies.sort_by(&:value)
          end

          def round_state
            {
              companies_pending_par: [],
            }
          end

          def auctioning
            nil
          end

          # min bid is face value or $5 higher than previous bid
          def min_bid(company)
            return 0 unless company

            high_bid = highest_bid(company)&.price || 0
            [high_bid + min_increment, company.min_bid].max
          end

          # min bid is face value, $5 higher than previous bid or $5 more than the bid being moved
          def min_move_bid(company, bid_to_move)
            return 0 unless company

            [min_bid(company), bid_to_move + min_increment].max
          end

          # can never purchase directly
          def may_purchase?(_company)
            false
          end

          def available_cash(player)
            player.cash - committed_cash(player)
          end

          def committed_cash(player, _show_hidden = false)
            player_bids = bids_for_player(player)
            return 0 if player_bids.empty?

            player_bids.sum(&:price)
          end

          def highest_player_bid(player, company)
            return unless (company_bids = @bids[company])

            company_bids&.select { |b| b.entity == player }&.max_by(&:price)
          end

          def current_bid_amount(player, company)
            highest_player_bid(player, company)&.price || 0
          end

          def max_move_bid(player, _company, from_price)
            available_cash(player) + from_price
          end

          def max_place_bid(player, company)
            available_cash(player) + current_bid_amount(player, company)
          end

          def max_bid(player, _company)
            player_highest_bid = bids_for_player(player).map { |b| b[:price] }.max || 0
            available_cash(player) + player_highest_bid
          end

          def moveable_bids(player, company)
            @bids.map do |cmp, company_bids|
              next if cmp == company

              player_bids = company_bids.select { |bid| bid.entity == player }
              next if player_bids.empty?

              [cmp, player_bids]
            end.compact.to_h
          end

          protected

          # every company is always up for auction
          def can_auction?(_company)
            true
          end

          def end_auction!
            # company is deleted from @companies when they are won, so we can't loop
            # through @companies instead of @bids.
            @bids.each do |company, bids|
              resolve_bids_for_company(company, bids)
            end

            # discount the price of remaining companies
            @companies.each do |company|
              company.max_price = company.min_price
            end

            return unless @game.drgr.owner.nil?

            @game.log << "#{@game.drgr.name} wasn't purchased and closes along with #{@game.dsng.name}"
            @game.drgr.close!
            @game.close_corporation(@game.dsng, quiet: true)
          end

          def resolve_bids_for_company(company, bids)
            return if bids.empty?

            high_bid = highest_bid(company)
            buy_company(high_bid.entity, company, high_bid.price)
          end

          def buy_company(player, company, price)
            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            @companies.delete(company)

            @log << "#{player.name} wins the auction for #{company.name} "\
                    "with #{@bids[company].size > 1 ? 'a' : 'the only'} "\
                    "bid of #{@game.format_currency(price)}"

            @game.abilities(company, :shares) do |ability|
              ability.shares.each do |share|
                if share.president
                  @round.companies_pending_par << company
                else
                  @game.share_pool.buy_shares(player, share, exchange: :free)
                end
              end
            end
          end

          def add_bid(bid)
            company = bid.company || bid.corporation
            entity = bid.entity
            price = bid.price
            min = min_bid(company)

            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if price < min

            if @game.class::MUST_BID_INCREMENT_MULTIPLE && ((price - min) % min_increment).nonzero?
              raise GameError, "Must increase bid by a multiple of #{@game.format_currency(min_increment)}"
            end

            if price > max_place_bid(entity, company)
              raise GameError, "Cannot afford #{@game.format_currency(price)} bid. "\
                               "Maximum possible bid is #{@game.format_currency(max_place_bid(entity, company))}"
            end

            player_bid = highest_player_bid(entity, company)
            @bids[company].delete(player_bid) if player_bid
            @bids[company] << bid

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{bid.company.name}"
          end

          def move_bid(bid)
            entity = bid.entity
            company = bid.company
            from_company = bid.from_company
            price = bid.price
            from_price = bid.from_price
            min = min_move_bid(company, from_price)

            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if price < min

            if @game.class::MUST_BID_INCREMENT_MULTIPLE && ((price - min) % min_increment).nonzero?
              raise GameError, "Must increase bid by a multiple of #{@game.format_currency(min_increment)}"
            end

            if price > max_move_bid(entity, company, from_price)
              raise GameError, "Cannot afford #{@game.format_currency(price)} movement bid. "\
                               "Maximum possible bid is #{@game.format_currency(max_move_bid(entity, company, from_price))}"
            end

            if price < from_price + min_increment
              raise GameError, "Bid of #{@game.format_currency(price)} is too low. "\
                               "Bid movement must increase original #{@game.format_currency(from_price)} bid "\
                               "by a multiple of #{@game.format_currency(min_increment)}"
            end

            @bids[from_company].reject! { |b| b.entity == entity && b.price == from_price }
            @bids[company] << bid

            @log << "#{entity.name} moves #{@game.format_currency(from_price)} bid from "\
                    "#{from_company.name} to bid #{@game.format_currency(price)} for #{bid.company.name}"
          end

          def bids_for_player(player)
            @bids.values.flat_map do |company_bids|
              company_bids.select { |bid| bid.entity == player }
            end
          end
        end
      end
    end
  end
end
