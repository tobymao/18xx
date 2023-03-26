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
            return unless @game.company_becomes_minor?(company)

            price = 180 if price > 180
            @game.bank.spend(price, @game.corporations.find { |minor| minor.name == company.sym })
          end
        end
      end
    end
  end
end
