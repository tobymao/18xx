# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'parrer'

module Engine
  module Game
    module G18EUS
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include Parrer
        end
      end
    end
  end
end
