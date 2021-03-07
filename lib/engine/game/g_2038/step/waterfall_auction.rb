# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'
require_relative '../company_wrapper'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def setup
            @log << "-- Using our setup"
            super

            @wrappedCompanies = @game.minors.map { |minor| CompanyWrapper.new(minor) }

            @companies = @companies + @wrappedCompanies
            @companies = @companies.sort_by(&:value)
            @cheapest = @companies.first

            @log << "-- Done"
          end

          def buy_company(player, company, price)

            # TODO: Handle our custom "company" here, otherwise super
          end
        end
      end
    end
  end
end
