# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end

          def visible_corporations
            # * hide debt company
            # * put metal companies always first
            @game.sorted_corporations.reject { |c| c.type == :debt }.sort_by { |c| c.type == :metal ? 0 : 1 }
          end
        end
      end
    end
  end
end
