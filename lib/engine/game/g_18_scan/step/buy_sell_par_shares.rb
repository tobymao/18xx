# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Scan
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def get_par_prices(entity, corp)
            return super unless corp == @game.sj

            @game.stock_market.par_prices.select do |p|
              p.price == @game.class::SJ_START_PRICE && p.price * 2 <= entity.cash
            end
          end
        end
      end
    end
  end
end
