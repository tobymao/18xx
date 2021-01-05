# frozen_string_literal: true

require_relative '../waterfall_auction'

module Engine
  module Step
    module G18SJ
      class WaterfallAuction < WaterfallAuction
        def buy_company(player, company, price)
          super

          # Give the buyer a one time priority deal steal if buying Nils Ericsson
          @game.priority_deal_chooser = player if company.id == 'NE'

          minor = @game.minor_khj

          return unless company.sym == minor&.name

          @game.log << "#{minor.name} floats"
          minor.owner = player
          minor.float!
        end
      end
    end
  end
end
