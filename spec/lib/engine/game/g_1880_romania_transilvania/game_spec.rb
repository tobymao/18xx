# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1880RomaniaTransilvania::Game do
    let(:players) { %w[Alice Bob] }
    let(:game) { Game::G1880RomaniaTransilvania::Game.new(players) }

    it 'initialises without error' do
      expect(game).to be_a(described_class)
    end

    it 'has the correct player range' do
      expect(described_class::PLAYER_RANGE).to eq([2, 2])
    end

    it 'has the correct game title' do
      expect(described_class::GAME_TITLE).to eq('1880 Romania Transilvania')
    end

    it 'has the correct development stage' do
      expect(described_class::DEV_STAGE).to eq(:alpha)
    end

    it 'depends on 1880 Romania' do
      expect(described_class::DEPENDS_ON).to eq('1880 Romania')
    end

    it 'has the correct starting cash for 2 players' do
      expect(described_class::STARTING_CASH).to eq({ 2 => 350 })
    end

    it 'has the correct cert limit for 2 players' do
      expect(described_class::CERT_LIMIT).to eq({ 2 => 11 })
    end

    describe 'game initialization' do
      it 'has the correct number of companies' do
        expect(game.companies.size).to eq(4)
      end

      it 'has the correct company symbols' do
        company_ids = game.companies.map(&:id)
        expect(company_ids).to contain_exactly('P1', 'P3', 'P5', 'P8')
      end

      it 'has the correct number of minors' do
        expect(game.minors.size).to eq(3)
      end

      it 'has the correct minor ids' do
        minor_ids = game.minors.map(&:id)
        expect(minor_ids).to contain_exactly('1', '4', '5')
      end

      it 'has the correct minor coordinates' do
        minor_coords = game.minors.to_h { |m| [m.id, m.coordinates] }
        expect(minor_coords['1']).to eq('D2')
        expect(minor_coords['4']).to eq('B8')
        expect(minor_coords['5']).to eq('J4')
      end

      it 'has the correct number of corporations' do
        expect(game.corporations.size).to eq(4)
      end

      it 'has the correct corporation ids' do
        corp_ids = game.corporations.map(&:id)
        expect(corp_ids).to contain_exactly('BR', 'CR', 'SZ', 'TR')
      end

      it 'has the correct corporation coordinates' do
        corp_coords = game.corporations.to_h { |c| [c.id, c.coordinates] }
        expect(corp_coords['BR']).to eq('D6')
        expect(corp_coords['CR']).to eq('E3')
        expect(corp_coords['SZ']).to eq('G1')
        expect(corp_coords['TR']).to eq('L6')
      end
    end

    describe 'train configuration' do
      it 'has the correct number of each train type' do
        train_counts = game.depot.trains.each_with_object({}) do |train, hash|
          hash[train.name] = hash.fetch(train.name, 0) + 1
        end
        expect(train_counts['2']).to eq(6)
        expect(train_counts['2+2']).to eq(3)
        expect(train_counts['3']).to eq(3)
        expect(train_counts['3+3']).to eq(2)
        expect(train_counts['4']).to eq(2)
        expect(train_counts['4+4']).to eq(2)
        expect(train_counts['6']).to eq(2)
        expect(train_counts['6E']).to eq(1)
        expect(train_counts['8']).to eq(1)
        expect(train_counts['2R']).to eq(6)
      end

      it 'has 2+2 train without open_borders event' do
        t_2p2 = game.depot.trains.find { |t| t.name == '2+2' }
        expect(t_2p2).not_to be_nil
        expect(t_2p2.events).to eq([])
      end

      it 'has 3+3 train with communist_takeover event' do
        t_3p3 = game.depot.trains.find { |t| t.name == '3+3' }
        expect(t_3p3).not_to be_nil
        expect(t_3p3.events).to eq([{ 'type' => 'communist_takeover' }])
      end

      it 'has 6E train with signal_end_game event' do
        t_6e = game.depot.trains.find { |t| t.name == '6E' }
        expect(t_6e).not_to be_nil
        expect(t_6e.events).to eq([{ 'type' => 'signal_end_game', 'when' => 1 }])
      end
    end

    describe 'par chart' do
      it 'returns a hash of share prices to par values' do
        expect(game.par_chart).to be_a(Hash)
      end

      it 'has entries for all share prices' do
        expect(game.par_chart.size).to eq(game.share_prices.size)
      end

      it 'has nil values for par chart' do
        game.par_chart.each do |_sp, par_values|
          expect(par_values).to eq([nil, nil])
        end
      end
    end

    describe 'dummy company for unused privates' do
      it 'returns dummy company for consortiu (P2)' do
        expect(game.consortiu).to be_a(Engine::Company)
        expect(game.consortiu.id).to eq('DUMMY')
        expect(game.consortiu.name).to eq('Dummy Company')
      end

      it 'returns dummy company for danube_port (P4)' do
        expect(game.danube_port).to be_a(Engine::Company)
        expect(game.danube_port.id).to eq('DUMMY')
      end

      it 'returns dummy company for malaxa (P6)' do
        expect(game.malaxa).to be_a(Engine::Company)
        expect(game.malaxa.id).to eq('DUMMY')
      end

      it 'returns dummy company for rocket (P7)' do
        expect(game.rocket).to be_a(Engine::Company)
        expect(game.rocket.id).to eq('DUMMY')
      end

      it 'dummy company is closed' do
        expect(game.consortiu.closed?).to be true
      end

      it 'all dummy methods return the same instance' do
        expect(game.consortiu).to eq(game.danube_port)
        expect(game.danube_port).to eq(game.malaxa)
        expect(game.malaxa).to eq(game.rocket)
      end
    end

    describe 'location names' do
      it 'has the correct location names from map' do
        expect(Game::G1880RomaniaTransilvania::Map::LOCATION_NAMES['G1']).to eq('Satu Mare')
        expect(Game::G1880RomaniaTransilvania::Map::LOCATION_NAMES['E3']).to eq('Oradea')
        expect(Game::G1880RomaniaTransilvania::Map::LOCATION_NAMES['J4']).to eq('Cluj-Napoca')
        expect(Game::G1880RomaniaTransilvania::Map::LOCATION_NAMES['L6']).to eq('Sibiu')
        expect(Game::G1880RomaniaTransilvania::Map::LOCATION_NAMES['D2']).to eq('Viena / Budapešta')
      end
    end

    describe 'map configuration' do
      it 'uses pointy layout' do
        expect(Game::G1880RomaniaTransilvania::Map::LAYOUT).to eq(:pointy)
      end

      it 'has the correct axes configuration' do
        expect(Game::G1880RomaniaTransilvania::Map::AXES).to eq({ x: :letter, y: :number })
      end

      it 'has hex definitions' do
        expect(Game::G1880RomaniaTransilvania::Map::HEXES).to be_a(Hash)
        expect(Game::G1880RomaniaTransilvania::Map::HEXES[:white]).to be_a(Hash)
        expect(Game::G1880RomaniaTransilvania::Map::HEXES[:gray]).to be_a(Hash)
        expect(Game::G1880RomaniaTransilvania::Map::HEXES[:red]).to be_a(Hash)
      end

      it 'has offboard locations' do
        hexes = Game::G1880RomaniaTransilvania::Map::HEXES
        expect(hexes[:red][['K7']]).to include('offboard')
        expect(hexes[:red][['M7']]).to include('offboard')
      end

      it 'has Istanbul offboard with correct revenue' do
        hexes = Game::G1880RomaniaTransilvania::Map::HEXES
        expect(hexes[:red][['K7']]).to include("offboard=revenue:yellow_10|green_20|brown_40|gray_50,hide:1,groups:Istanbul")
      end
    end
  end
end
