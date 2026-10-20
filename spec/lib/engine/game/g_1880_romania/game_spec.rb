# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1880Romania::Game do
  let(:map) { Engine::Game::G1880Romania::Map }
  let(:meta) { Engine::Game::G1880Romania::Meta }

  def new_game(players, rules = [])
    described_class.new(players, optional_rules: rules)
  end

  describe 'full map' do
    let(:game) { described_class.new(%w[a b c]) }

    it 'has 112 hexes' do
      expect(game.hexes.size).to eq(112)
    end

    it 'has borders on exactly the hexes listed in BORDERS' do
      bordered = game.hexes.reject { |hex| hex.tile.borders.empty? }.map(&:id).sort

      expect(bordered).to eq(map::BORDERS.keys.sort)
    end

    it 'has impassable borders on exactly the listed edges' do
      map::BORDERS.each do |coord, edges|
        borders = game.hex_by_id(coord).tile.borders

        expect(borders.map(&:edge).sort).to eq(edges.sort)
        expect(borders.map(&:type).uniq).to eq([:impassable])
      end
    end
  end

  describe 'map regions' do
    let(:regions) { [map::KINGDOM_OF_ROMANIA_HEXES, map::TRANSYLVANIA_HEXES, map::FULL_MAP_HEXES] }

    def coords(hexes)
      hexes.values.flat_map(&:keys).flatten
    end

    it 'has disjoint Kingdom of Romania and Transylvania coordinates' do
      kingdom = coords(map::KINGDOM_OF_ROMANIA_HEXES)
      transylvania = coords(map::TRANSYLVANIA_HEXES)

      expect(kingdom.size).to eq(64)
      expect(transylvania.size).to eq(43)
      expect(kingdom & transylvania).to be_empty
    end

    it 'has no borders in the region constants' do
      tile_strings = regions.flat_map { |hexes| hexes.values.flat_map(&:values) }

      expect(tile_strings.grep(/border=/)).to be_empty
    end
  end

  describe 'player counts' do
    it 'rejects 2 players without a variant' do
      expect { new_game(%w[a b]) }.to raise_error(Engine::GameError, /does not support 2 players/)
    end

    it 'allows 3 and 6 players without a variant' do
      expect { new_game(%w[a b c]) }.not_to raise_error
      expect { new_game(%w[a b c d e f]) }.not_to raise_error
    end

    it 'allows 2 and 3 players with the Kingdom of Romania rule' do
      expect { new_game(%w[a b], [:kingdom_of_romania]) }.not_to raise_error
      expect { new_game(%w[a b c], [:kingdom_of_romania]) }.not_to raise_error
    end

    it 'drops the Kingdom of Romania rule at 4 players' do
      game = new_game(%w[a b c d], [:kingdom_of_romania])

      expect(game.optional_rules).not_to include(:kingdom_of_romania)
      expect(game.hexes.size).to eq(112)
    end

    it 'validates options' do
      expect(meta.check_options([], 2, 4)).to include(:error)
      expect(meta.check_options([], 3, 6)).to be_nil
      expect(meta.check_options(['kingdom_of_romania'], 2, 4)).to include(:error)
      expect(meta.check_options(['kingdom_of_romania'], 2, 3)).to be_nil
      expect(meta.check_options([:kingdom_of_romania], nil, nil)).to be_nil
    end
  end

  describe 'kingdom of romania' do
    let(:game) { new_game(%w[a b], [:kingdom_of_romania]) }

    it 'is flagged as the active variant' do
      expect(game.kingdom_of_romania?).to be(true)
      expect(game.transylvania?).to be(false)
      expect(game.variant).to eq(Engine::Game::G1880Romania::KingdomOfRomania)
    end

    it 'has no variant in the base game' do
      base = new_game(%w[a b c])

      expect(base.kingdom_of_romania?).to be(false)
      expect(base.variant).to be_nil
    end

    it 'has 68 hexes without borders' do
      expect(game.hexes.size).to eq(68)
      expect(game.hexes.reject { |hex| hex.tile.borders.empty? }).to be_empty
    end

    it 'has the Viena / Budapesta gateway on G9' do
      tile = game.hex_by_id('G9').tile

      expect(tile.color).to eq(:red)
      expect(tile.cities.size).to eq(1)
      expect(tile.exits.sort).to eq([0, 4, 5])
    end

    it 'has the Cluj-Napoca offboard on B16' do
      tile = game.hex_by_id('B16').tile

      expect(tile.color).to eq(:red)
      expect(tile.offboards.size).to eq(1)
      expect(tile.exits.sort).to eq([3, 4])
    end

    it 'has no upgrades on H8 and a L20 mountain on I7' do
      expect(game.hex_by_id('H8').tile.upgrades).to be_empty
      expect(game.hex_by_id('I7').tile.upgrades.map(&:cost)).to eq([20])
    end

    it 'names the new border hexes' do
      expect(game.hex_by_id('B16').location_name).to eq('Cluj-Napoca')
      expect(game.hex_by_id('G9').location_name).to eq('Viena / Budapešta')
    end

    it 'keeps the Kingdom corporations, minors and companies' do
      expect(game.corporations.map(&:id).sort).to eq(%w[Bess CFR DR GWR LCR LWR MR VRL])
      expect(game.minors.map(&:id)).to eq(%w[1 2 3 6])
      expect(game.minor_by_id('1').coordinates).to eq('G9')
      expect(game.companies.map(&:id)).to eq(%w[P1 P4 P5 P6 P7])
    end

    it 'restricts the Danube port hexes to those on the map' do
      ability = game.company_by_id('P4').all_abilities.find { |a| a.type == :assign_hexes }

      expect(ability.hexes).to eq(%w[G23 G25 J20 K9 K17])
    end

    it 'does not mutate the shared company constants' do
      game

      ability = Engine::Game::G1880Romania::Entities::COMPANIES.find { |c| c[:sym] == 'P4' }[:abilities].first
      expect(ability[:hexes]).to eq(%w[G23 G25 H4 J20 K9 K17])
    end

    it 'uses the 2-3 player cash and certificate limits' do
      expect(game.players.map(&:cash)).to eq([700, 700])
      expect(game.cert_limit).to eq(22)

      three = new_game(%w[a b c], [:kingdom_of_romania])
      expect(three.players.map(&:cash)).to eq([500, 500, 500])
      expect(three.cert_limit).to eq(18)
    end

    it 'has the reduced train roster' do
      expect(game.depot.trains.map(&:name).tally).to eq(
        '2' => 8, '2+2' => 4, '3' => 4, '3+3' => 4, '4' => 4, '4+4' => 4,
        '6' => 2, '6E' => 1, '8' => 1, '8E' => 1, '2R' => 10
      )
    end

    it 'has no border events and ends the game on the single 6E' do
      events = game.depot.trains.flat_map(&:events).map { |event| event['type'] }
      six_e = game.depot.trains.find { |train| train.name == '6E' }

      expect(events).not_to include('open_borders', 'remove_borders')
      expect(six_e.events.map { |event| event['type'] }).to include('signal_end_game')
    end
  end

  describe 'base game' do
    let(:game) { new_game(%w[a b c]) }

    it 'keeps the full entity roster' do
      expect(game.corporations.size).to eq(12)
      expect(game.minors.size).to eq(6)
      expect(game.companies.size).to eq(8)
    end

    it 'keeps the border events on the 2+2' do
      train = game.depot.trains.find { |t| t.name == '2+2' }

      expect(train.events.map { |event| event['type'] }).to include('open_borders')
    end
  end
end
