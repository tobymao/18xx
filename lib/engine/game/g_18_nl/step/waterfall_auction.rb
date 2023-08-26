# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18NL
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            setup_auction
            @companies = @game.companies.sort_by(&:value)
            @cheapest = @companies[0]
            @second_cheapest = @companies[1]
            @bidders = Hash.new { |h, k| h[k] = [] }
          end

          def all_passed!
            # in 18NL, the discount is applied to the two lowest priced private companies.
            if @companies.include?(@cheapest) && @companies.include?(@second_cheapest)
              increase_discount!(@cheapest, 5)
              increase_discount!(@second_cheapest, 5)
            elsif @companies.include?(@second_cheapest)
              increase_discount!(@second_cheapest, 5)
            else
              @game.payout_companies
              @game.or_set_finished
            end

            entities.each(&:unpass!)
          end
        end
      end
    end
  end
end
