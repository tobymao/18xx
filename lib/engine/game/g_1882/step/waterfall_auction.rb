# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G1882
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def buy_company(player, company, price)
            super

            # Update cheapest so that passing causes it's price to drop
            @cheapest = @companies.first
          end
        end
      end
    end
  end
end
