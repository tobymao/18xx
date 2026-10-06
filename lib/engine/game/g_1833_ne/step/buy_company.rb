# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          include ReceivershipSkip

          def process_buy_company(action)
            super

            @game.lowell_merchants_company_purchased = true if action.company.id == 'P2'
          end
        end
      end
    end
  end
end
