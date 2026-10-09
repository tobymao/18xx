# frozen_string_literal: true

def pass(entity)
  game.process_action(Engine::Action::Pass.new(entity)).maybe_raise!
end

def buy(player, company_id)
  game.process_action(Engine::Action::Bid.new(player, company: game.company_by_id(company_id),
                                                      price: game.company_by_id(company_id).value)).maybe_raise!
end

def buy_shares(player, corporation_id, percent = nil, other_player = nil)
  corp = game.corporation_by_id(corporation_id)
  unless other_player
    return game.process_action(Engine::Action::BuyShares.new(player,
                                                             shares: corp.shares.find(&:buyable))).maybe_raise!
  end

  game.process_action(Engine::Action::BuyShares.new(player, shares: other_player.shares_of(corp).find do |share|
    share.percent == percent
  end)).maybe_raise!
end
