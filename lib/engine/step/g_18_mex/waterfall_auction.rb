# frozen_string_literal: true

require_relative '../waterfall_auction'

module Engine
  module Step
    module G18Mex
      class WaterfallAuction < WaterfallAuction
        protected

        def buy_company(player, company, price)
          super

          return unless (minor = @game.minor_by_id(company.sym))

          @game.log << "Minor #{minor.name} floats"
          minor.owner = player
          minor.float!
        end
      end
    end
  end
end
