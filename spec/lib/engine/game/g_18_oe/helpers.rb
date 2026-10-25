# frozen_string_literal: true

module G18OESpecHelpers
  def new_game(players = %w[a b c], klass: Engine::Game::G18OE::Game, optional_rules: [])
    klass.new(players, seed: 1, optional_rules: optional_rules)
  end

  def act!(target, action)
    target.process_action(action)
    raise "#{action.class} by #{action.entity.name}: #{target.exception}" if target.is_a?(Engine::Game::Base) && target.exception

    target
  end

  def cell(game, price, type = nil)
    game.stock_market.market.flatten.compact.find { |sp| sp.price == price && (type.nil? || sp.type == type) }
  end

  def fund!(game, entity, amount = 2000)
    game.bank.spend(amount, entity)
    entity
  end

  def give_company!(player, company)
    company.owner = player
    player.companies << company
    company
  end

  def start_regional!(game, id, player, par: 60)
    regional = game.corporation_by_id(id)
    fund!(game, player)
    game.par_corporation(regional, cell(game, par, :par))
    game.share_pool.buy_shares(player, regional.shares.first)
    game.place_home_token(regional)
    game.minor_regional_order << regional
    regional
  end

  def float_regionals!(game, count, except: [])
    player = game.players.first
    game.corporations.select { |corporation| corporation.type == :regional && !corporation.ipoed }
      .reject { |corporation| except.include?(corporation.id) }
      .first(count)
      .each { |corporation| start_regional!(game, corporation.id, player) }
  end

  def start_major!(game, id, player)
    regional = start_regional!(game, id, player)
    Engine::Game::G18OE::Step::BuySellParShares.new(game, []).float_major(regional)
    regional
  end

  def start_minor!(game, id, player, zone)
    minor = game.corporation_by_id(id)
    game.share_pool.buy_shares(player, minor.shares.first.to_bundle, exchange: :free)
    fund!(game, minor, 120)
    game.claim_region!(minor, zone)
    game.minor_regional_order << minor
    minor
  end

  def take_treasury_shares!(game, player, corporation, count)
    fund!(game, player)
    count.times { game.share_pool.buy_shares(player, corporation.ipo_shares.first) }
  end

  def convert!(round, regional)
    president = regional.owner
    act!(round, Engine::Action::Convert.new(regional))
    act!(round, Engine::Action::Pass.new(president))
    act!(round, Engine::Action::BuyShares.new(president, shares: regional.ipo_shares.first, percent: 10))
    act!(round, Engine::Action::Pass.new(president)) if round.current_entity == president
    regional
  end

  def pass_until!(round, player)
    act!(round, Engine::Action::Pass.new(round.current_entity)) until round.current_entity == player
  end

  def lay_first_legal!(game, round, hex_id)
    entity = round.active_step.current_entity
    hex = game.hex_by_id(hex_id)
    tile = round.active_step.upgradeable_tiles(entity, hex).first
    act!(round, Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: tile.legal_rotations.first))
    tile
  end

  def enter_round!(game, round)
    game.instance_variable_set(:@round, round)
    round
  end

  def stock_round!(game, turn: 2)
    game.instance_variable_set(:@turn, turn)
    enter_round!(game, game.stock_round)
  end

  def round_step(round, klass)
    round.steps.find { |s| s.is_a?(klass) }
  end
end
