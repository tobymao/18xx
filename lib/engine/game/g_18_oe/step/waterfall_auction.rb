# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18OE
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            super
            @companies = @companies.sort_by { |c| [c.auction_row, c.value, c.sym] }
          end

          def tiered_auction_companies
            @companies.group_by(&:auction_row).values
          end

          def may_purchase?(company)
            tiered_auction_companies.first.include?(company)
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
            row.each do |company|
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
