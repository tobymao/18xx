# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18OE
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
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

            # if the company is a minor, max 180 goes into the treasury
          end
        end
      end
    end
  end
end
