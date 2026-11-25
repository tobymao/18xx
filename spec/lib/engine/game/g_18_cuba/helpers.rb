# frozen_string_literal: true

module G18CubaSpecHelpers
  def act(klass, entity = game.current_entity, **args)
    game.process_action(klass.new(entity, **args)).maybe_raise!
  end

  def float_major!(corporation)
    until game.round.is_a?(Engine::Round::Stock)
      step = game.round.active_step
      company = game.round.is_a?(Engine::Round::Auction) && step.companies.first
      company && step.bids[company].empty? ? act(Engine::Action::Bid, company: company, price: 0) : act(Engine::Action::Pass)
    end
    act(Engine::Action::Par, corporation: corporation, share_price: game.stock_market.par_prices.first)
    act(Engine::Action::BuyShares, shares: corporation.ipo_shares.first,
                                   share_price: corporation.share_price.price) until corporation.floated?
  end

  def depot_train(name)
    game.depot.depot_trains.find { |t| t.name == name } ||
      game.depot.upcoming.find { |t| t.name == name }
  end

  def give_train(corp, name)
    train = depot_train(name)
    return nil unless train

    game.depot.remove_train(train)
    train.owner = corp
    corp.trains << train
    train
  end
end
