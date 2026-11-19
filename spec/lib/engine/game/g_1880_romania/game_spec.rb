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

  describe 'transylvania' do
    let(:game) { new_game(%w[a b], [:transylvania]) }

    def tile_of(id)
      game.hex_by_id(id).tile
    end

    it 'creates with 2 players and drops the rule at 3' do
      expect { game }.not_to raise_error
      expect(game.transylvania?).to be(true)
      expect(game.kingdom_of_romania?).to be(false)
      expect(game.variant).to eq(Engine::Game::G1880Romania::Transylvania)

      three = new_game(%w[a b c], [:transylvania])
      expect(three.optional_rules).not_to include(:transylvania)
      expect(three.hexes.size).to eq(112)
    end

    it 'cannot be combined with the Kingdom of Romania rule' do
      expect { new_game(%w[a b], %i[kingdom_of_romania transylvania]) }.to raise_error(Engine::OptionError)
    end

    it 'validates options' do
      expect(meta.check_options(%w[kingdom_of_romania transylvania], 2, 2)).to include(:error)
      expect(meta.check_options(['transylvania'], 2, 3)).to include(:error)
      expect(meta.check_options(['transylvania'], 2, 2)).to be_nil
    end

    it 'has 48 hexes without province borders' do
      borders = game.hexes.flat_map { |hex| hex.tile.borders }

      expect(game.hexes.size).to eq(48)
      expect(borders.map(&:type)).not_to include(:impassable, :province)
      expect(game.hexes.reject { |hex| hex.tile.borders.empty? }.map(&:id).sort).to eq(%w[G11 G13])
    end

    it 'has the Cernauti offboard on A17' do
      tile = tile_of('A17')

      expect(tile.color).to eq(:red)
      expect(tile.offboards.size).to eq(1)
      expect(tile.exits).to eq([0])
    end

    it 'has the Radauti town on B16' do
      tile = tile_of('B16')

      expect(tile.color).to eq(:gray)
      expect(tile.towns.size).to eq(1)
      expect(tile.exits.sort).to eq([0, 1, 3])
    end

    it 'has the F16 city' do
      tile = tile_of('F16')

      expect(tile.color).to eq(:gray)
      expect(tile.cities.size).to eq(1)
      expect(tile.exits.sort).to eq([1, 2])
    end

    it 'has the Istanbul offboards on G11 and G13' do
      expect(tile_of('G11').color).to eq(:red)
      expect(tile_of('G13').color).to eq(:red)
      expect(tile_of('G11').exits).to eq([3])
      expect(tile_of('G13').exits).to eq([2])
      expect(tile_of('G11').offboards.first.revenue_to_render[:yellow]).to eq(10)
      expect(tile_of('G13').offboards.first.revenue_to_render[:yellow]).to eq(10)
    end

    it 'leaves H2 as on the full map' do
      full = described_class.new(%w[a b c]).hex_by_id('H2').tile
      tile = tile_of('H2')

      expect(tile.color).to eq(full.color)
      expect(tile.exits.sort).to eq(full.exits.sort)
      expect(tile.cities.size).to eq(full.cities.size)
    end

    it 'names the Istanbul hex' do
      expect(game.hex_by_id('G11').location_name).to eq('Istanbul')
    end

    it 'has the Transylvania corporations, minors and companies' do
      expect(game.corporations.map(&:id).sort).to eq(%w[BR CR SZ TR])
      expect(game.minors.map(&:id)).to eq(%w[1 4 5])
      expect(game.companies.map(&:id)).to eq(%w[P1 P3 P5 P8])
    end

    it 'uses the 2 player cash and certificate limit' do
      expect(game.players.map(&:cash)).to eq([350, 350])
      expect(game.cert_limit).to eq(11)
    end

    it 'has the reduced train roster' do
      expect(game.depot.trains.map(&:name).tally).to eq(
        '2' => 6, '2+2' => 3, '3' => 3, '3+3' => 2, '4' => 2, '4+4' => 2,
        '6' => 2, '6E' => 1, '8' => 1, '8E' => 1, '2R' => 10
      )
    end

    it 'has no border events and ends the game on the single 6E' do
      events = game.depot.trains.flat_map(&:events).map { |event| event['type'] }
      six_e = game.depot.trains.find { |train| train.name == '6E' }

      expect(events).not_to include('open_borders', 'remove_borders')
      expect(six_e.events.map { |event| event['type'] }).to include('signal_end_game')
    end

    describe 'without the privates Transylvania does not use' do
      it 'survives the communist takeover' do
        expect { game.event_communist_takeover! }.not_to raise_error
      end

      it 'has no forced rocket exchange' do
        allow(game.phase).to receive(:name).and_return('B2')

        expect(game.forced_exchange_rocket?).to be(false)
      end

      it 'has no Danube port bonus' do
        route = double(corporation: game.corporations.first)
        stops = [double(hex: game.hex_by_id('C5'))]

        expect(game.danube_port_bonus?(route, stops)).to be(false)
      end

      it 'calculates route revenue without the ferry company' do
        route = double(corporation: game.corporations.first, all_hexes: [])

        expect(game.revenue_for(route, [])).to eq(0)
      end

      it 'buys a train that triggers a stock round' do
        allow(game).to receive(:trigger_sr?).and_return(true)
        allow(game).to receive(:transition_to_next_round!)
        train = game.depot.trains.find { |t| t.name == '4' }

        expect { game.after_buying_train(train, game.depot) }.not_to raise_error
      end

      it 'does not block track laying on a missing Malaxa' do
        step = Engine::Game::G1880Romania::Step::Track.new(game, game.round)
        allow(game).to receive(:can_build_track?).and_return(false)

        expect { step.tile_lay_abilities_should_block?(game.corporations.first) }.not_to raise_error
      end
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
