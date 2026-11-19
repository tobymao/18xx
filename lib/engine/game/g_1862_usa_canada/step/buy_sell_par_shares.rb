# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          # NHSC gives the buyer NYH's director cert; NYH must be parred at
          # exactly $100. Restrict available par prices to that single value.
          def get_par_prices(entity, corporation)
            nhsc = @game.company_by_id('NHSC')
            return super if corporation&.id != 'NYH' || !nhsc || nhsc.closed?

            @game.stock_market.par_prices.select { |p| p.price == 100 && entity.cash >= p.price * 3 }
          end
        end
      end
    end
  end
end
