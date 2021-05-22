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
    entity = action.entity
    return exchange_for_rag(action, entity) if entity.company?

    # In case president's share is reserved, do not change presidency
    corporation = action.bundle.corporation
    allow_president_change = corporation.presidents_share.buyable
    buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: allow_president_change)
    track_action(action, corporation)
    @round.last_to_act = action.entity
    @round.current_actions << action
  end

  def exchange_for_rag(action, entity)
    buy_shares(entity.player, action.bundle, exchange: true, exchange_price: 0)
    @round.last_to_act = entity.player
    @round.current_actions << action
  end
end
