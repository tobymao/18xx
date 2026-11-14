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

  def float_minor!(minor, player, concession_id = 'M1')
    float_minors!(minor => [player, concession_id])
  end

  def float_minors!(floats)
    until game.round.is_a?(Engine::Round::Draft)
      step = game.round.active_step
      company = step.companies.first
      step.bids[company].empty? ? act(Engine::Action::Bid, company: company, price: 0) : act(Engine::Action::Pass)
    end
    until game.round.is_a?(Engine::Round::Stock)
      _, (_, concession_id) = floats.find { |_, (player, _)| player == game.current_entity }
      concession = concession_id && game.company_by_id(concession_id)
      next act(Engine::Action::Pass) if !concession || concession.owner

      act(Engine::Action::Bid, company: concession, price: concession.value)
    end
    until floats.keys.all?(&:floated?)
      minor, (player, _concession_id) = floats.find { |m, (pl, _)| pl == game.current_entity && !m.floated? }
      next act(Engine::Action::Pass) unless minor

      act(Engine::Action::Par, player, corporation: minor, share_price: game.stock_market.par_prices.find { |p| p.price == 70 })
      city = game.home_token_locations(minor).flat_map { |h| h.tile.cities }.find { |c| c.tokenable?(minor, free: true) }
      act(Engine::Action::PlaceToken, city: city, slot: city.get_slot(minor), tokener: minor)
    end
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
