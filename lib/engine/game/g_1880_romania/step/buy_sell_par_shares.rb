# frozen_string_literal: true

require_relative '../../g_1880/step/buy_sell_par_shares'
require_relative 'parrer'

module Engine
  module Game
    module G1880Romania
      module Step
        class BuySellParShares < G1880::Step::BuySellParShares
          include Parrer
        end
      end
    end
  end
end
