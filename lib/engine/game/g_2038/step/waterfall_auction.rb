# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def buy_company(player, company, price)
            super

            return unless company.instance_of?(G2038::Company)

            company.close!   # remove our wrapper which was added in super.buy_company
            minor = @game.minors.find { |m| m.id == company.minor_id }
            minor.owner = player
            minor.float!
            capital = (price - 100) / 2
            @game.bank.spend(100 + capital, minor)
          end
        end
      end
    end
  end
end
