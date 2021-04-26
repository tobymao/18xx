# frozen_string_literal: true

require_relative '../../g_1817/step/buy_sell_par_shares'

module Engine
  module Game
    module G1817DE
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          def can_short?(_entity, _corporation)
            false
          end
        end
      end
    end
  end
end
