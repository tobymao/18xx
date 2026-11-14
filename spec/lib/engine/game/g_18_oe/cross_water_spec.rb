# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE graph across water (§11.1.3, §11.3.6)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:dsj) { game.corporation_by_id('DSJ') }

  def token!(hex_id, corporation)
    city = game.hex_by_id(hex_id).tile.cities.first
    city.place_token(corporation, corporation.next_token, free: true, check_tokenable: false)
  end

  def lay!(hex_id, name, rotation)
    tile = game.tiles.find { |t| t.name == name && !t.hex }
    tile.rotate!(rotation)
    game.hex_by_id(hex_id).lay(tile)
    tile
  end

  it 'lands at a public port with only the port edge, then walks on once track meets the arrow (§11.3.6, §11.1.3)' do
    token!('I50', dsj)
    game.graph.clear
    expect(game.graph.connected_hexes(dsj)[game.hex_by_id('K60')]).to eq([3])
    expect(game.graph.connected_nodes(dsj)).not_to have_key(game.hex_by_id('K60').tile.towns.first)
    lay!('K60', '4', 0)
    game.clear_graph
    expect(game.graph.connected_nodes(dsj)).to have_key(game.hex_by_id('K60').tile.towns.first)
    expect(game.graph.connected_hexes(dsj)).to have_key(game.hex_by_id('L59'))
  end

  it 'does not enter a private port without a token there (§11.3.6)' do
    token!('I50', dsj)
    game.graph.clear
    expect(game.graph.connected_hexes(dsj)).not_to have_key(game.hex_by_id('I52'))
  end

  it 'connects an offshore city with every edge and offers it for a token (§11.3.6)' do
    token!('I50', dsj)
    game.graph.clear
    christiania = game.hex_by_id('C48').tile.cities.first
    expect(game.graph.connected_nodes(dsj)).to have_key(christiania)
    expect(game.graph.connected_hexes(dsj)[game.hex_by_id('C48')].sort).to eq([0, 1, 2, 3, 4, 5])
    expect(game.graph.reachable_hexes(dsj)).to have_key(game.hex_by_id('C48'))
    expect(game.graph.can_token?(dsj)).to be(true)
    expect(game.graph.tokenable_cities(dsj)).to include(christiania)
  end

  it 'keeps the offshore city reachable after a routes-only compute (§11.3.6)' do
    token!('I50', dsj)
    landing = { game.hex_by_id('C48') => { 0 => true } }
    nodes = [game.hex_by_id('C48').tile.cities.first]
    allow(game.graph).to receive(:sea_network).with(dsj).and_return(double(landings: landing, landing_nodes: nodes))
    game.clear_graph
    game.graph.route_info(dsj)
    expect(game.graph.reachable_hexes(dsj)).to have_key(game.hex_by_id('C48'))
  end

  it 'does not connect a full city reached only by sea (§11.3.6)' do
    token!('I50', dsj)
    lay!('H21', '57', 1)
    token!('H21', game.corporation_by_id('GSWR'))
    game.clear_graph
    expect(game.graph.connected_nodes(dsj)).not_to have_key(game.hex_by_id('H21').tile.cities.first)
  end

  it 'does not run through an offboard reached only by sea (§11.3.6)' do
    token!('I50', dsj)
    game.clear_graph
    expect(game.graph.connected_hexes(dsj)).not_to have_key(game.hex_by_id('AF49'))
  end

  it 'offers no hex it cannot token from a home token alone (§11.2.1)' do
    token!('I50', dsj)
    game.clear_graph
    expect(game.graph.reachable_hexes(dsj)).not_to have_key(game.hex_by_id('D57'))
  end

  it 'keeps ports out of the merge graph (§10.5)' do
    gswr = game.corporation_by_id('GSWR')
    token!('I50', dsj)
    lay!('H21', '57', 1)
    game.clear_graph
    expect(game.graph.connected_nodes(dsj)).to have_key(game.hex_by_id('H21').tile.cities.first)
    token!('H21', gswr)
    game.clear_graph
    expect(game.merge_connected?(gswr, dsj)).to be(false)
  end

  it 'sees a private port once the corporation tokens its city' do
    token!('I50', dsj)
    game.clear_graph
    expect(game.graph.sea_network(dsj).usable?('I52', 0)).to be(false)
    token!('I52', dsj)
    game.clear_graph_for_entity(dsj)
    expect(game.graph.sea_network(dsj).usable?('I52', 0)).to be(true)
  end

  it 'drops every network when any entity clears the graph' do
    token!('I50', dsj)
    before = game.graph.sea_network(dsj)
    game.clear_graph_for_entity(game.corporation_by_id('GSWR'))
    expect(game.graph.sea_network(dsj)).not_to equal(before)
  end

  describe 'laying across water (§11.1.3, §11.1.6)' do
    let(:player) { game.players.first }

    def or_with_dsj!
      start_regional!(game, 'DSJ', player)
      enter_round!(game, game.operating_round(1))
    end

    def tile(name, rotation) = game.tiles.find { |t| t.name == name && !t.hex }.tap { |t| t.rotate!(rotation) }

    it 'rejects a tile that does not meet the port arrow' do
      round = or_with_dsj!
      expect { act!(round, Engine::Action::LayTile.new(dsj, tile: tile('3', 4), hex: game.hex_by_id('D41'), rotation: 4)) }
        .to raise_error(/not legally rotated/)
    end

    it 'charges £10 per sea zone on top of the terrain cost' do
      round = or_with_dsj!
      cash = dsj.cash
      act!(round, Engine::Action::LayTile.new(dsj, tile: tile('4', 0), hex: game.hex_by_id('D41'), rotation: 0))
      expect(cash - dsj.cash).to eq(36 + 10)
      expect(game.log.map(&:message)).to include('DSJ spends £46 and lays tile #4 with rotation 0 on D41 (Stavanger)')
    end

    it 'charges the fee for the rotation in the action when the tile arrives unrotated, as on replay' do
      round = or_with_dsj!
      unrotated = tile('4', 1)
      cash = dsj.cash
      act!(round, Engine::Action::LayTile.new(dsj, tile: unrotated, hex: game.hex_by_id('D41'), rotation: 0))
      expect(cash - dsj.cash).to eq(36 + 10)
    end

    it 'records the fee on the action' do
      round = or_with_dsj!
      action = Engine::Action::LayTile.new(dsj, tile: tile('4', 0), hex: game.hex_by_id('D41'), rotation: 0)
      act!(round, action)
      expect(action.extra_cost).to eq(10)
    end

    it 'trusts the recorded fee on replay without building a sea network' do
      round = or_with_dsj!
      game.instance_variable_set(:@loading, true)
      expect(Engine::Game::G18OE::SeaNetwork).not_to receive(:new)
      cash = dsj.cash
      act!(round, Engine::Action::LayTile.new(dsj, tile: tile('4', 1), hex: game.hex_by_id('D41'), rotation: 0, extra_cost: 10))
      expect(cash - dsj.cash).to eq(36 + 10)
    end

    it 'rejects a recorded fee that differs from the computed one' do
      round = or_with_dsj!
      expect do
        act!(round, Engine::Action::LayTile.new(dsj, tile: tile('4', 0), hex: game.hex_by_id('D41'), rotation: 0, extra_cost: 20))
      end
        .to raise_error(Engine::GameError, /Cross-water fee is £10, not £20/)
    end

    it 'charges £5 per ferry distance when the ferry is cheaper than the ports' do
      gswr = game.corporation_by_id('GSWR')
      token!('I20', gswr)
      expect(game.cross_water_tile_fee(gswr, game.hex_by_id('J23'), tile('4', 2))).to eq(5)
    end
  end

  describe 'tokens across water (§11.2.1)' do
    def or_at_token_step!
      start_regional!(game, 'DSJ', game.players.first)
      round = enter_round!(game, game.operating_round(1))
      act!(round, Engine::Action::Pass.new(dsj))
      round
    end
    let(:christiania) { game.hex_by_id('C48').tile.cities.first }

    it 'charges £40 per sea zone for three zones (§11.2.1 example)' do
      lnwr = game.corporation_by_id('LNWR')
      token!('M28', lnwr)
      expect(game.cross_water_token_fee(lnwr, christiania)).to eq(120)
    end

    it 'charges the token price plus £40 for one zone' do
      round = or_at_token_step!
      cash = dsj.cash
      act!(round, Engine::Action::PlaceToken.new(dsj, city: christiania, slot: 0))
      expect(cash - dsj.cash).to eq(20 + 40)
      expect(game.log.map(&:message)).to include('DSJ places a token on C48 (Christiania)  for £60')
    end

    it 'records the fee on the action' do
      round = or_at_token_step!
      action = Engine::Action::PlaceToken.new(dsj, city: christiania, slot: 0)
      act!(round, action)
      expect(action.cost).to eq(60)
    end

    it 'trusts the recorded fee on replay without building a sea network' do
      round = or_at_token_step!
      game.clear_graph
      game.instance_variable_set(:@loading, true)
      action = Engine::Action::PlaceToken.new(dsj, city: christiania, slot: 0, cost: 60)
      expect(Engine::Game::G18OE::SeaNetwork).not_to receive(:new)
      cash = dsj.cash
      round.active_step.process_place_token(action)
      expect(cash - dsj.cash).to eq(20 + 40)
    end

    it 'rejects a recorded fee that differs from the computed one' do
      round = or_at_token_step!
      expect { act!(round, Engine::Action::PlaceToken.new(dsj, city: christiania, slot: 0, cost: 20)) }
        .to raise_error(Engine::GameError, /Token costs £60, not £20/)
    end
  end
end
