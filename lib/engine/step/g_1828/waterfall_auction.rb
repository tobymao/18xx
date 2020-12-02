# frozen_string_literal: true

require_relative '../waterfall_auction'

module Engine
  module Step
    module G1828
      class WaterfallAuction < WaterfallAuction
        def may_purchase?(company)
          return false if @companies.first.value != company.value || @bids[company].any?

          rest_of_row_has_bids?(company)
        end

        def can_auction?(company)
          return true if @process_round_end_auction && @bids[company].size > 1

          super
        end

        protected

        def resolve_bids
          if @process_round_end_auction
            @companies.each do |company|
              resolve_bids_for_company(company)
              break if @auctioning == company
            end

            round_end_auction_complete if all_bids_processed?
          else
            super
          end
        end

        def resolve_bids_for_company(company)
          return super if @process_round_end_auction || rest_of_row_has_bids?(company)

          false
        end

        def all_passed!
          @process_round_end_auction = true
          resolve_bids
        end

        def placement_bid(new_bid)
          super

          @bids[new_bid.company]&.reject! { |bid| new_bid.entity != bid.entity } if new_bid.company.value == 250
        end

        def buy_company(player, company, price)
          super

          return unless (minor = @game.minor_by_id(company.id))

          minor.owner = player
          minor.float!
        end

        private

        def round_end_auction_complete
          @process_round_end_auction = false

          @game.payout_companies
          @game.or_set_finished

          entities.each(&:unpass!)
        end

        def all_bids_processed?
          @bids.values.flatten.empty?
        end

        def rest_of_row_has_bids?(company)
          @companies.each do |c|
            next if c.value != company.value || c == company

            return false if @bids[c].empty?
          end

          true
        end
      end
    end
  end
end
