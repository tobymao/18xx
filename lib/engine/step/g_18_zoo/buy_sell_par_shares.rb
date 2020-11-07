# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18ZOO
      class BuySellParShares < BuySellParShares
        #TODO: Player cannot buy more than 60% from IPO

        def purchasable_companies(entity)
          return [] if bought? ||
              !entity.cash.positive? ||
              !@game.phase.status.include?('can_buy_companies_from_other_players')

          @game.purchasable_companies(entity)
        end
      end
    end
  end
end
