# frozen_string_literal: true

require_relative '../waterfall_auction'

module Engine
  module Step
    module G1828
      class WaterfallAuction < WaterfallAuction
        def may_purchase?(company)
          return false unless @companies.first.value == company.value && @bids[company].empty?

          rest_of_row_has_bids?(company)
        end

        def can_auction?(company)
          return true if @process_round_end_auction && @bids[company].count > 1

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
          return false unless @process_round_end_auction || rest_of_row_has_bids?(company)

          super
        end

        def all_passed!
          @process_round_end_auction = true
          resolve_bids
        end

        def placement_bid(new_bid)
          super

          @bids[new_bid.company]&.reject! { |bid| new_bid.entity != bid.entity } if new_bid.company.value == 250
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
          @companies.find_all { |c| c.value == company.value }.each do |c|
            return false if @bids[c].empty? && c != company
          end

          true
        end
      end
    end
  end
end
