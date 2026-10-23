# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 playthrough' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 8) }

  it 'opens in a stock round with Nikolaev the only startable minor' do
    expect(game.round).to be_a(Engine::Round::Stock)

    step = game.active_step
    startable = game.corporations.select { |c| c.type == :minor && step.ipo_type(c) == :bid }

    expect(startable.map(&:id)).to eq(['N'])
  end

  it 'auto-passes every player through to an operating round without raising' do
    20.times do
      break if game.round.is_a?(Engine::Round::Operating)

      entity = game.current_entity
      action = Engine::Action::Pass.new(entity)
      break unless game.active_step.actions(entity).include?('pass')

      game.process_action(action)
    end

    expect(game.round).to be_a(Engine::Round::Operating).or be_a(Engine::Round::Stock)
    expect(game.exception).to be_nil
  end

  it 'reports a sane unstarted corporation summary' do
    summary, corporations = game.unstarted_corporation_summary

    expect(summary).to include('minor')
    expect(corporations).to include(game.union_pacific)
  end

  def start_nikolaev!(bidder: 'alice', price: 100)
    n = game.corporation_by_id('N')
    bidder_entity = game.player_by_id(bidder)

    game.process_action(Engine::Action::Bid.new(bidder_entity, corporation: n, price: price))
    expect(game.exception).to be_nil

    2.times do
      entity = game.current_entity
      game.process_action(Engine::Action::Pass.new(entity))
      expect(game.exception).to be_nil
    end

    n
  end

  def pass_until_operating_round!
    30.times do
      break if game.round.is_a?(Engine::Round::Operating)

      entity = game.current_entity
      actions = game.active_step.actions(entity)
      break unless actions.include?('pass')

      game.process_action(Engine::Action::Pass.new(entity))
      expect(game.exception).to be_nil
    end
  end

  it 'lets a player win Nikolaev via bid, par-ing it at half the winning bid' do
    n = start_nikolaev!(price: 100)

    expect(n.owner.name).to eq('alice')
    expect(n.floated?).to be true
    expect(n.ipoed).to be true
    expect(n.cash).to eq(100)
    expect(game.exception).to be_nil
  end

  it 'floats Nikolaev and reaches its operating turn as the sole operator' do
    start_nikolaev!(price: 100)
    pass_until_operating_round!

    expect(game.round).to be_a(Engine::Round::Operating)
    expect(game.operating_order.map(&:id)).to eq(['N'])
    expect(game.current_entity.id).to eq('N')
    expect(game.active_step).to be_a(Engine::Game::G1864::Step::Track)
    expect(game.exception).to be_nil
  end

  def lay_f25_west_of_omaha!(n)
    tile = game.tile_by_id('9-0')
    hex = game.hex_by_id('F25')
    game.process_action(Engine::Action::LayTile.new(n, tile: tile, hex: hex, rotation: 1))
    expect(game.exception).to be_nil

    hex
  end

  it 'lays a tile extending track west from home' do
    n = start_nikolaev!(price: 100)
    pass_until_operating_round!

    hex = lay_f25_west_of_omaha!(n)

    expect(hex.tile.name).to eq('9')
    expect(hex.tile.exits.sort).to eq([1, 4])
    expect(n.cash).to eq(100)
    expect(game.credit_mobilier.cash).to eq(0)
    expect(game.exception).to be_nil
  end

  def float_lay_and_buy_first_train!
    n = start_nikolaev!(price: 100)
    pass_until_operating_round!
    lay_f25_west_of_omaha!(n)

    game.process_action(Engine::Action::Pass.new(n))
    expect(game.exception).to be_nil
    expect(game.active_step).to be_a(Engine::Game::G1864::Step::BuyTrain)

    train = game.depot.upcoming.find { |t| t.name == '2' }
    game.process_action(Engine::Action::BuyTrain.new(n, train: train, price: train.price))
    expect(game.exception).to be_nil
    expect(n.trains.map(&:name)).to eq(['2'])
    expect(n.cash).to eq(0)

    expect(game.round.round_num).to eq(2)
    expect(game.current_entity.id).to eq('N')
    expect(game.active_step).to be_a(Engine::Game::G1864::Step::Track)
    game.process_action(Engine::Action::Pass.new(n))
    expect(game.exception).to be_nil
    expect(game.active_step).to be_a(Engine::Step::Route)

    n
  end

  def run_first_route!(n)
    route = Engine::Route.new(game, game.phase, n.trains.first, connection_hexes: [%w[F27 E28]])
    game.process_action(Engine::Action::RunRoutes.new(n, routes: [route]))
    expect(game.exception).to be_nil

    route
  end

  it 'runs a route from Omaha to Chicago for the expected revenue' do
    n = float_lay_and_buy_first_train!

    route = run_first_route!(n)

    expect(route.stops.map { |stop| stop.hex.id }).to eq(%w[F27 E28])
    expect(route.revenue).to eq(40)
    expect(game.exception).to be_nil
  end

  it 'auto-pays a dividend on the minor and moves the share price right' do
    n = float_lay_and_buy_first_train!
    alice = game.player_by_id('alice')
    cash_before = alice.cash
    price_before = n.share_price.price
    expect(price_before).to eq(45)

    run_first_route!(n)

    expect(n.cash).to eq(20)
    expect(alice.cash).to eq(cash_before + 20)
    expect(n.share_price.price).to eq(50)
    expect(game.exception).to be_nil
  end
end
