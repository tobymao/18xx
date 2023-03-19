# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18OE
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def tiered_auction_companies
            @companies.group_by(&:value).values
          end

          def min_bid(company)
            return unless company
            return company.min_bid if may_purchase?(company)

            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : company.min_bid
          end
        end
      end
    end
  end
end
