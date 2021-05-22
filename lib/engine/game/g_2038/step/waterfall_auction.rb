# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def may_purchase?(company)
            return false unless super
            return true if @purchasing_first_minor

            !minor?(company)
          end

          def can_auction?(company)
            return true if @process_round_end_auction && @bids[company].size > 1

            super
          end

          def min_bid(company)
            return unless company
            return company.min_bid if may_purchase?(company)

            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : company.min_bid
          end

          def bid_str(company)
            !auctioning && company && minor?(company) && company == @companies.first ? 'Buy' : 'Place Bid'
          end

          def placement_bid(bid)
            @purchasing_first_minor = bid.company && bid.company == @companies.first
            super
            @purchasing_first_minor = false
          end

          def minor?(company)
            @game.minors.any? { |m| m.id == company.id }
          end

          def buy_company(player, company, price)
            super

            return unless (minor = @game.minor_by_id(company.id))

            minor.owner = player
            minor.float!
            capital = (price - 100) / 2
            @game.bank.spend(100 + capital, minor)
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
            resolve_bids
          end

          def round_end_auction_complete
            @process_round_end_auction = false

            @game.payout_companies
            @game.or_set_finished

            entities.each(&:unpass!)
          end

          def all_bids_processed?
            @bids.values.flatten.empty?
          end
        end
      end
    end
  end
end
