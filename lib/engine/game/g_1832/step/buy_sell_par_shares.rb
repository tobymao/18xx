# frozen_string_literal: true

require_relative '../../g_1870/step/buy_sell_par_shares'

module Engine
  module Game
    module G1832
      module Step
        class BuySellParShares < G1870::Step::BuySellParShares
          def visible_corporations
            @game.sorted_corporations.reject { |item| item.type == :system unless item.floated? }
          end
        end
      end
    end
  end
end
