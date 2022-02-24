# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G18Scan
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          protected

          def buy_company(player, company, price)
            super

            return unless (minor = @game.minor_by_id(company.sym))

            @game.log << "Minor #{minor.name} floats"
            minor.owner = player
            minor.float!
            @game.place_home_token(minor)
            @game.bank.spend(price, minor)
          end
        end
      end
    end
  end
end
