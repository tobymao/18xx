# frozen_string_literal: true

require_relative 'stock_market'

module Engine
  module Game
    module G1850
      class StockMarket < Engine::StockMarket
        # Possible pars after reissuing, with their coordinates on the stock market
        ISSUE_PAR_PRICES = {
          68 => [6, 7],
          72 => [5, 7],
          76 => [4, 7],
          82 => [3, 7],
          90 => [2, 7],
          100 => [1, 7],
          110 => [1, 8],
          120 => [1, 9],
          140 => [1, 10],
          160 => [1, 11],
          180 => [1, 12],
          200 => [1, 13],
        }.freeze

        def move_right(corporation)
          r, c = corporation.share_price.coordinates

          return move_up(corporation) if @market.dig(r, c + 1)&.type == :ignore_one_sale

          super
        end

        def issue_par(corporation)
          ISSUE_PAR_PRICES.keys
            .reject { |v| v > 0.75 * corporation.share_price.price }
            .concat([corporation.par_price.price])
            .max
        end

        def update_par!(corporation)
          if issue_par(corporation) > corporation.par_price.price
            corporation.par_price = ISSUE_PAR_PRICES[issue_par(corporation)]

            @log << "#{corporation.name}'s par price is now #{@game.format_currency(action.entity.par_price.price)}"
          end

          corporation.capitalization = :incremental
        end
      end
    end
  end
end
