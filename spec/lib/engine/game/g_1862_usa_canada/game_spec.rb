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
  end
end
