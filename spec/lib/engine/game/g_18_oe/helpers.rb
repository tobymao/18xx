# frozen_string_literal: true

module G18OESpecHelpers
  def new_game(players = %w[a b c], seed: 1, klass: Engine::Game::G18OE::Game)
    klass.new(players, seed: seed)
  end

  def act!(game, action)
    game.process_action(action)
    raise "#{action.class} by #{action.entity.name}: #{game.exception}" if game.exception

    game
  end

  def buy_top_row!(game)
    step = game.round.active_step
    company = step.companies.find { |c| step.may_purchase?(c) }
    act!(game, Engine::Action::Bid.new(game.current_entity, company: company, price: step.min_bid(company)))
    company
  end

  def finish_auction!(game)
    buy_top_row!(game) while game.round.is_a?(Engine::Round::Auction)
    game
  end

  def home_city(game, minor, zone)
    hex = game.home_token_locations(minor).find { |h| game.region_for_hex(h) == zone }
    hex.tile.cities.find { |c| c.tokenable?(minor, free: true) }
  end

  def float_minor!(game, minor_id, zone:)
    player = game.current_entity
    minor = game.corporation_by_id(minor_id)
    price = game.round.active_step.get_par_prices(player, minor).first
    act!(game, Engine::Action::Par.new(player, corporation: minor, share_price: price))
    act!(game, Engine::Action::PlaceToken.new(minor, city: home_city(game, minor, zone), slot: 0))
    minor
  end

  def float_regional!(game, regional_id, par: 60)
    regional = game.corporation_by_id(regional_id)
    act!(game, Engine::Action::Par.new(game.current_entity, corporation: regional, share_price: cell(game, par, :par)))
    regional
  end

  def float_everything!(game, regionals: 18, regional_par: 60)
    while game.round.is_a?(Engine::Round::Stock)
      entity = game.current_entity
      step = game.round.active_step
      if step.is_a?(Engine::Step::HomeToken)
        hex = game.home_token_locations(entity).first
        city = hex.tile.cities.find { |c| c.tokenable?(entity, free: true) }
        act!(game, Engine::Action::PlaceToken.new(entity, city: city, slot: 0))
      elsif (company = entity.companies.find { |c| game.company_becomes_minor?(c) })
        minor = game.corporation_by_id(company.sym)
        act!(game, Engine::Action::Par.new(entity, corporation: minor, share_price: step.get_par_prices(entity, minor).first))
      elsif (regional = next_regional(game, entity, regionals, regional_par))
        act!(game, Engine::Action::Par.new(entity, corporation: regional, share_price: cell(game, regional_par, :par)))
      else
        act!(game, Engine::Action::Pass.new(entity))
      end
    end
    game
  end

  def next_regional(game, player, regionals, par)
    return if game.regional_corps_floated >= regionals
    return unless game.round.active_step.actions(player).include?('par')

    capital = par * 2
    spare = player.cash - promised_train_cash(game, player)
    game.corporations.find do |c|
      c.type == :regional && !c.ipoed && !c.closed? && spare >= capital + train_shortfall(game, capital - c.tokens.first.price)
    end
  end

  def promised_train_cash(game, player)
    game.corporations
      .select { |c| c.floated? && c.trains.empty? && c.owner == player }
      .sum { |c| train_shortfall(game, c.cash) }
  end

  def train_shortfall(game, cash)
    [game.depot.upcoming.first.price - cash, 0].max
  end

  def or_step!(game)
    entity = game.current_entity
    step = game.round.active_step
    actions = step.actions(entity)
    if actions.include?('buy_train') && step.must_buy_train?(entity)
      train = step.buyable_trains(entity).min_by(&:price)
      act!(game, Engine::Action::BuyTrain.new(entity, train: train, price: train.price))
    elsif actions.include?('run_routes')
      act!(game, Engine::Action::RunRoutes.new(entity, routes: []))
    elsif actions.include?('dividend')
      act!(game, Engine::Action::Dividend.new(entity, kind: 'withhold'))
    else
      act!(game, Engine::Action::Pass.new(entity))
    end
  end

  def finish_or!(game)
    round = game.round
    or_step!(game) while game.round.equal?(round) && !game.finished && game.round.active_step
    game
  end

  def finish_sr!(game)
    round = game.round
    act!(game, Engine::Action::Pass.new(game.current_entity)) while game.round.equal?(round) && !game.finished
    game
  end

  def pass_until!(game, player)
    act!(game, Engine::Action::Pass.new(game.current_entity)) until game.current_entity == player
  end

  def advance_to!(game, corp_id)
    corporation = game.corporation_by_id(corp_id)
    or_step!(game) until game.current_entity == corporation
    corporation
  end

  def game_at_or1(players: %w[a b c], seed: 1, regionals: 18, regional_par: 60)
    game = finish_auction!(new_game(players, seed: seed))
    float_everything!(game, regionals: regionals, regional_par: regional_par)
  end

  def game_at_sr2(**opts)
    game = game_at_or1(**opts)
    finish_or!(game)
    finish_or!(game)
  end

  def convert!(game, regional)
    president = regional.owner
    act!(game, Engine::Action::Convert.new(regional))
    act!(game, Engine::Action::Pass.new(president))
    act!(game, Engine::Action::BuyShares.new(president, shares: regional.ipo_shares.first, percent: 10))
    act!(game, Engine::Action::Pass.new(president)) if game.current_entity == president
    regional
  end

  def lay_first_legal!(game, hex_id)
    entity = game.current_entity
    hex = game.hex_by_id(hex_id)
    tile = game.round.active_step.upgradeable_tiles(entity, hex).first
    act!(game, Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: tile.legal_rotations.first))
    tile
  end

  def round_step(game, klass)
    game.round.steps.find { |s| s.is_a?(klass) }
  end

  def cell(game, price, type = nil)
    game.stock_market.market.flatten.compact.find { |sp| sp.price == price && (type.nil? || sp.type == type) }
  end

  def ors_until_end!(game)
    played = []
    until game.finished || played.size > 12
      if game.round.is_a?(Engine::Round::Operating)
        played << "#{game.turn}.#{game.round.round_num}"
        finish_or!(game)
      else
        finish_sr!(game)
      end
    end
    played
  end
end
