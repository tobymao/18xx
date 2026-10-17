# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 phase events' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }

  it 'opens the Moffat Tunnel and Lucin Cutoff at phase 5' do
    Engine::Game::G1864::Map::TUNNEL_TILES.keys.each do |hex_id|
      tile = game.hex_by_id(hex_id).tile
      expect(tile.paths).to be_empty
      expect(tile.stubs.map(&:edge).sort).to eq([1, 4])
      expect(tile.towns.size).to eq(1)
    end

    game.event_open_tunnels!

    Engine::Game::G1864::Map::TUNNEL_TILES.keys.each do |hex_id|
      tile = game.hex_by_id(hex_id).tile
      expect(tile.paths.size).to eq(2)
      expect(tile.stubs).to be_empty
      expect(tile.towns.size).to eq(1)
    end
  end

  it 'cannot route across the tunnels before phase 5 but can after' do
    { 'G18' => %w[G16 G20], 'F11' => %w[F9 F13] }.each do |hex_id, (west_id, east_id)|
      hex = game.hex_by_id(hex_id)

      expect(hex.tile.exits).to be_empty

      expect(hex.neighbors[1]).to eq(game.hex_by_id(west_id))
      expect(hex.neighbors[4]).to eq(game.hex_by_id(east_id))
    end

    game.event_open_tunnels!

    Engine::Game::G1864::Map::TUNNEL_TILES.keys.each do |hex_id|
      expect(game.hex_by_id(hex_id).tile.exits.sort).to eq([1, 4])
    end
  end

  it 'uses 1867 game end timing, not 1861 conditional timing' do
    expect(game.method(:game_end_set_final_turn!).owner)
      .to eq(Engine::Game::G1867::Game)
  end

  it 'offers Deregulation as an optional rule' do
    syms = Engine::Game::G1864::Meta::OPTIONAL_RULES.map { |r| r[:sym] }

    expect(syms).to include(:deregulation)
  end

  it 'removes the train limit in the final three ORs under Deregulation' do
    dereg = Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1,
                                                               optional_rules: [:deregulation])
    corp = dereg.corporations.first
    normal = dereg.train_limit(corp)
    allow(corp).to receive(:trains).and_return(Array.new(normal + 3) { instance_double(Engine::Train) })

    expect(dereg.train_limit(corp)).to eq(normal)

    dereg.instance_variable_set(:@final_turn, dereg.turn)

    expect(dereg.train_limit(corp)).to eq(normal + 4)
  end

  it 'exports trains from phase 4 to phase 7 only' do
    statuses = Engine::Game::G1864::Game::PHASES.to_h { |phase| [phase[:name], phase[:status]] }

    expect(statuses.select { |_, status| status.include?('export_train') }.keys).to eq(%w[4 5 6 7])
  end

  describe 'Bailey Yard' do
    let(:yellow) { game.tiles.find { |t| t.name == 'X6' } }
    let(:brown) { game.tiles.find { |t| t.name == 'X7' } }
    let(:gray) { game.tiles.find { |t| t.name == 'X8' } }

    it 'upgrades the striped yellow tile straight to brown' do
      expect(game.upgrades_to?(yellow, brown)).to be(true)
    end

    it 'does not allow the gray tile before phase 7' do
      allow(game.phase).to receive(:name).and_return('6')
      expect(game.upgrades_to?(brown, gray)).to be(false)

      allow(game.phase).to receive(:name).and_return('7')
      expect(game.upgrades_to?(brown, gray)).to be(true)
    end
  end
end
