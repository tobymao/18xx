# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_companies'

module Engine
  module Game
    module G18Carolinas
      module Step
        class BuySellParSharesCompanies < Engine::Step::BuySellParSharesCompanies
          def process_buy_shares(action)
            super
            @game.check_new_layer
          end
        end
      end
    end
  end
end
