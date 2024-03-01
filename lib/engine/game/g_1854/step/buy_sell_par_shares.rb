# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1854
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def visible_corporations
            @game.sorted_corporations.reject(&:closed?).reject { |c| c.type == :lokalbahn }
          end
        end
      end
    end
  end
end
