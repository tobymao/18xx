# frozen_string_literal: true

# This module is used by the buy and par steps of 1893

module ParAndBuy
  def process_par(action)
    corporation = action.corporation

    super

    @log << "Remaining 80% of #{corporation.name} are moved to market"
    @game.move_buyable_shares_to_market(corporation)
  end

  def process_buy_shares(action)
    # In case president's share is reserved, do not change presidency
    allow_president_change = action.bundle.corporation.presidents_share.buyable
    buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: allow_president_change)
    @round.last_to_act = action.entity
    @current_actions << action
  end
end
