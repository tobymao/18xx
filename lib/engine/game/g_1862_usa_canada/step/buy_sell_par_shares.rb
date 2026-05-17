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
            return nyh_par_prices if corporation.id == 'NYH'

            super
          end

          private

          def nyh_par_prices
            [@game.stock_market.par_prices.find { |p| p.price == 100 }].compact
          end
        end
      end
    end
  end
end
