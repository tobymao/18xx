# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1862UsaCanada::Game do
    let(:players) { %w[Alice Bob Charlie] }
    let(:game) { Game::G1862UsaCanada::Game.new(players) }

    it 'initialises without error' do
      expect(game).to be_a(described_class)
    end

    it 'has the correct number of corporations' do
      expect(game.corporations.size).to eq(13)
    end

    it 'has the correct number of private companies' do
      expect(game.companies.size).to eq(8)
    end

    it 'starts in phase 2' do
      expect(game.phase.name).to eq('2')
    end

    it 'uses full capitalisation' do
      expect(described_class::CAPITALIZATION).to eq(:full)
    end

    it 'uses sell_buy order' do
      expect(described_class::SELL_BUY_ORDER).to eq(:sell_buy)
    end

    describe 'tile-lay budget' do
      it 'phase 2: single yellow tile only' do
        lays = game.tile_lays(game.corporations.first)
        expect(lays.size).to eq(1)
        expect(lays.first[:upgrade]).to be false
      end

      it 'phase 3+: two entries, second blocked after upgrade' do
        game.phase.next!
        lays = game.tile_lays(game.corporations.first)
        expect(lays.size).to eq(2)
        expect(lays.first[:upgrade]).to be true
        expect(lays.last[:lay]).to eq(:not_if_upgraded)
        expect(lays.last[:upgrade]).to be false
      end

      it 'phase 3 status includes two_tile_lays flag' do
        game.phase.next!
        expect(game.phase.status).to include('two_tile_lays')
      end
    end

    describe 'E-train variants' do
      it 'every base train 2–7 has exactly one E-train variant' do
        base_trains = game.depot.trains.map(&:name).uniq.reject { |n| n == '8' }
        base_trains.each do |name|
          proto = game.depot.trains.find { |t| t.name == name }
          expect(proto.variants.keys).to include("#{name}E"), "#{name}-train missing #{name}E variant"
        end
      end

      it 'E-train distance uses string keys and visit 999' do
        %w[2E 3E 4E 5E 6E 7E].each do |variant_name|
          base = variant_name.chomp('E')
          proto = game.depot.trains.find { |t| t.name == base }
          dist = proto.variants[variant_name][:distance]
          expect(dist).to be_an(Array), "#{variant_name} distance should be an array"
          expect(dist.first['visit']).to eq(999), "#{variant_name} should visit 999 nodes"
          expect(dist.first['nodes']).to include('city'), "#{variant_name} nodes should include city"
        end
      end

      it '2 and 2E trains rust on the 4-train sym' do
        two_train = game.depot.trains.find { |t| t.name == '2' }
        expect(two_train.rusts_on).to eq('4')
      end

      it '3 and 3E trains rust on the 6-train sym' do
        three_train = game.depot.trains.find { |t| t.name == '3' }
        expect(three_train.rusts_on).to eq('6')
      end

      it '4 and 4E trains rust on the 8-train sym' do
        four_train = game.depot.trains.find { |t| t.name == '4' }
        expect(four_train.rusts_on).to eq('8')
      end

      it '5E and later trains never rust' do
        %w[5 6 7 8].each do |name|
          train = game.depot.trains.find { |t| t.name == name }
          expect(train.rusts_on).to be_nil, "#{name}-train should not rust"
        end
      end
    end

    describe 'home token timing' do
      it 'uses :operate timing' do
        expect(described_class::HOME_TOKEN_TIMING).to eq(:operate)
      end

      it 'clears the graph after placing the home token' do
        corp = game.corporations.first
        graph = game.send(:graph_for_entity, corp)
        expect(graph).to receive(:clear).at_least(:once)
        game.place_home_token(corp)
      end
    end

    describe 'corporation group unlock' do
      let(:nyh) { game.corporation_by_id('NYH') }
      let(:nyc) { game.corporation_by_id('NYC') }
      let(:cp)  { game.corporation_by_id('CP') }
      let(:cpr) { game.corporation_by_id('CPR') }
      let(:np)  { game.corporation_by_id('NP') }

      it 'Group 1 is locked while privates are unsold' do
        expect(game.can_par?(nyh, nil)).to be false
      end

      it 'Group 1 unlocks when all privates are sold' do
        game.companies.each { |c| c.owner = game.players.first }
        expect(game.can_par?(nyh, nil)).to be true
      end

      it 'Group 2 is locked even after all privates are sold' do
        game.companies.each { |c| c.owner = game.players.first }
        expect(game.can_par?(cpr, nil)).to be false
      end

      it 'Group 2 unlocks when all Group 1 IPO shares are sold' do
        game.companies.each { |c| c.owner = game.players.first }
        [nyh, nyc, cp].each { |corp| allow(corp).to receive(:num_ipo_shares).and_return(0) }
        expect(game.can_par?(cpr, nil)).to be true
      end

      it 'Group 3 is locked while any Group 2 corp is unfloated' do
        game.companies.each { |c| c.owner = game.players.first }
        expect(game.can_par?(np, nil)).to be false
      end
    end
  end
end
