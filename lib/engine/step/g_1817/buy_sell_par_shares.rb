# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        def actions(entity)
          actions = super
          actions << 'bid' # if can bid
          # actions << 'place_home_token' if @bid
          actions
        end

        # def process_par(action)
        #   super
        #   # All corps choose their home token at IPO time

        #   @game.place_home_token(action.corporation)

        #   # @todo: then go to an auction
        # end

        def committed_cash
          0
        end

        def can_ipo_any?(entity)
          false
        end
      end
    end
  end
end
