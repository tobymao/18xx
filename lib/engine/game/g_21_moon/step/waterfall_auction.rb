# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G21Moon
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def all_passed!
            companies_without_bids = @companies.reject { |c| @bids[c] && !@bids[c].empty? }.sort_by(&:value)

            end_auction! if companies_without_bids.empty?

            # cheapest company without a bid gets decreased by 10
            company = companies_without_bids.first
            value = company.min_bid
            company.discount += 10
            new_value = company.min_bid
            @game.log << "#{company.name} minimum bid decreases from "\
                         "#{@game.format_currency(value)} to #{@game.format_currency(new_value)}"

            return if new_value.positive?

            # It's now free so the next player is forced to buy it
            @round.next_entity_index!
            buy_company(current_entity, company, 0)
            resolve_bids
          end
        end
      end
    end
  end
end
