# frozen_string_literal: true

require_relative '../waterfall_auction'

module Engine
  module Step
    module G1882
      class WaterfallAuction < WaterfallAuction
        def buy_company(player, company, price)
          super

          # Update cheapest so that passing causes it's price to drop
          @cheapest = @companies.first
        end
      end
    end
  end
end
