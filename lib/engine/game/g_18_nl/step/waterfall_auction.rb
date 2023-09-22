# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18NL
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            super
            @second_cheapest = @companies[1]
          end

          def all_passed!
            if @companies.include?(@cheapest)
              increase_discount!(@cheapest, 5)
            # in 18NL, the discount is applied to P2 if P1 is bought, P2 has no bids, and everyone passes.
            elsif !@companies.include?(@cheapest) && @companies.include?(@second_cheapest)
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
