# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'
require_relative '../company'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            @log << "-- Using our setup"
            super

            @wrappedCompanies = @game.minors.map { |minor| G2038::Company.new(minor) }

            @companies = @companies + @wrappedCompanies
            @companies = @companies.sort_by(&:value)
            @cheapest = @companies.first

            @log << "-- Done"
          end

          def buy_company(player, company, price)
            super

            return unless (company.instance_of? (G2038::Company))

            company.close!   # remove our wrapper which was added in super.buy_company
            minor = company.minor
            minor.owner = player
            minor.float!
            capital = (price - 100) / 2
            minor.cash = 100 + capital
          end
        end
      end
    end
  end
end
