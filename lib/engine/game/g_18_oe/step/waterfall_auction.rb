# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18OE
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            super
            @companies = @companies.sort_by { |c| [c.auction_row, c.value, c.sym[/\d+/].to_i, c.sym] }
            @open_company = nil
            @open_bidders = []
          end

          def tiered_auction_companies
            @companies.group_by(&:auction_row).values
          end

          def may_purchase?(company)
            active_auction { return false }

            top_row?(company) && !@game.company_becomes_minor?(company)
          end

          def bid_str(company)
            return 'Place Bid' if @open_company

            top_row?(company) && @game.company_becomes_minor?(company) ? 'Buy / Bid' : 'Place Bid'
          end

          def auctioning
            @open_company || super
          end

          def process_bid(action)
            return super unless @open_company

            raise GameError, "#{@open_company.name} is at auction" unless action.company == @open_company

            action.entity.unpass!
            add_bid(action)
            advance_open_auction!
          end

          def process_pass(action)
            return super unless @open_company

            @log << "#{action.entity.name} passes on #{@open_company.name}"
            @bids[@open_company].reject! { |bid| bid.entity == action.entity }
            @open_bidders.delete(action.entity)
            advance_open_auction!
          end

          def active_entities
            return super unless @open_company

            [open_bidder_after(highest_bid(@open_company).entity)]
          end

          def actions(entity)
            return super unless @open_company
            return [] if @companies.empty? || entity != current_entity

            ACTIONS
          end

          def min_bid(company)
            return unless company
            return company.min_bid if may_purchase?(company)

            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : company.min_bid
          end

          def buy_company(player, company, price)
            super
            return unless @game.company_becomes_minor?(company)

            treasury_amount = [price, @game.class::MINOR_MAX_TREASURY].min
            @game.bank.spend(treasury_amount, @game.corporations.find { |minor| minor.name == company.sym })
          end

          protected

          def top_row?(company)
            tiered_auction_companies.first.include?(company)
          end

          def placement_bid(bid)
            company = bid.company
            return super unless top_row?(company)

            face_value = company.min_bid
            price = bid.price
            raise GameError, "Minimum bid is #{@game.format_currency(face_value)} for #{company.name}" if price < face_value
            return purchase_at_face_value!(bid) if price == face_value
            unless @game.company_becomes_minor?(company)
              raise GameError, "#{company.name} can only be bought for #{@game.format_currency(face_value)}"
            end

            start_open_auction!(bid)
          end

          def purchase_at_face_value!(bid)
            @round.last_to_act = bid.entity
            @auction_triggerer = bid.entity
            accept_bid(bid)
            resolve_bids
          end

          def start_open_auction!(bid)
            company = bid.company
            add_bid(bid)
            @log << "#{company.name} goes up for auction among all players"
            @open_company = company
            @open_bidders = entities.rotate(entities.index(bid.entity) + 1)
            @bidders[company] |= @open_bidders
            advance_open_auction!
          end

          def advance_open_auction!
            high_bid = highest_bid(@open_company)
            floor = high_bid.price + min_increment
            priced_out = (@open_bidders - [high_bid.entity]).select { |player| max_bid(player, @open_company) < floor }
            priced_out.each do |player|
              @log << "#{player.name} cannot bid #{@game.format_currency(floor)} for #{@open_company.name} and is out"
              @bids[@open_company].reject! { |bid| bid.entity == player }
              @open_bidders.delete(player)
            end
            finish_open_auction!(high_bid) if @open_bidders == [high_bid.entity]
          end

          def finish_open_auction!(high_bid)
            @open_company = nil
            @open_bidders = []
            accept_bid(high_bid)
            resolve_bids
          end

          def open_bidder_after(player)
            @open_bidders[(@open_bidders.index(player) + 1) % @open_bidders.size]
          end

          def resolve_bids
            while (row = tiered_auction_companies.first)
              contested = row.find { |company| @bids[company].any? && !resolve_bids_for_company(company) }
              return if contested || row.any? { |company| @companies.include?(company) }
            end
          end

          def can_auction?(company)
            tiered_auction_companies.first.include?(company) && @bids[company].size > 1
          end

          def all_passed!
            @game.payout_companies
            @game.or_set_finished
            reduce_top_row!
            entities.each(&:unpass!)
          end

          def reduce_top_row!
            row = tiered_auction_companies.first
            row.select { |company| company.min_bid.positive? }.each do |company|
              value = company.min_bid
              company.discount += 5
              @log << "#{company.name} minimum bid decreases from "\
                      "#{@game.format_currency(value)} to #{@game.format_currency(company.min_bid)}"
            end

            free = row.reject { |company| company.min_bid.positive? }
            return if free.empty?

            @round.next_entity_index!
            free.each { |company| buy_company(current_entity, company, 0) }
            resolve_bids
          end
        end
      end
    end
  end
end
