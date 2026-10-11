# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G1833NE
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def min_bid(company)
            return company.min_bid if may_purchase?(company)

            high_bid = highest_bid(company)
            return company.min_bid unless high_bid

            high_bid.price + min_increment
          end

          def resolve_bids
            if @process_round_end_auction
              @companies.dup.each do |company|
                resolve_bids_for_company(company)
                break if @auctioning == company
              end

              round_end_auction_complete if all_bids_processed?
            else
              super
            end
          end

          def all_passed!
            @process_round_end_auction = true

            if @bids.values.all?(&:empty?)
              @log << '-- All players passed - No current bids. Running two special operating rounds --'
              return round_end_auction_complete
            end

            @log << '-- All players passed - resolve current bids and then run two special operating rounds --'
            resolve_bids
          end

          def all_bids_processed?
            @bids.values.flatten.empty?
          end

          def round_end_auction_complete
            @process_round_end_auction = false

            @log << '-- First special operating round --'
            @game.payout_companies
            @log << '-- Second special operating round --'
            @game.payout_companies
            @game.or_set_finished

            entities.each(&:unpass!)
            @log << '-- Resume auction round --'
          end

          def resolve_bids_for_company(company)
            resolved = false
            is_new_auction = company != @auctioning
            @auctioning = nil
            bids = @bids[company]

            if bids.one?
              accept_bid(bids.first)
              resolved = true
            elsif can_auction?(company)
              @auctioning = company
              @log << "#{@auctioning.name} goes up for auction" if is_new_auction
            end

            resolved
          end

          def can_auction?(company)
            @bids[company].size > 1
          end
        end
      end
    end
  end
end
