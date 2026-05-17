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
