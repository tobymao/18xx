# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares

        def process_par(action)
          super
          # All corps choose their home token at IPO time

          @game.place_home_token(action.corporation)

          # @todo: then go to an auction
        end
      end
    end
  end
end
