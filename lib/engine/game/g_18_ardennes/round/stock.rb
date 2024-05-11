# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18Ardennes
      module Round
        class Stock < Engine::Round::Stock
          def show_auto?
            active_step.is_a?(G18Ardennes::Step::BuySellParSharesCompanies)
          end
        end
      end
    end
  end
end
