# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1864::Game do
  it 'uses 1864 starting cash and certificate limits' do
    { 2 => [530, 31], 3 => [353, 21], 4 => [265, 16], 5 => [212, 13], 6 => [176, 11] }
      .each do |count, (cash, certs)|
      expect(described_class::STARTING_CASH[count]).to eq(cash)
      expect(described_class::CERT_LIMIT[count]).to eq(certs)
    end
  end

  it 'uses the 1867 column market, not 1861 grid' do
    game = described_class.new(%w[alice bob carol], seed: 1)

    expect(game.game_market).to eq(described_class::COLUMN_MARKET)
  end

  it 'has no phase 8 trade-in discounts by default' do
    game = described_class.new(%w[alice bob carol], seed: 1)
    eight = game.depot.trains.find { |t| t.name == '8' }

    expect(eight.price).to eq(1000)
    expect(eight.discount).to be_nil
    expect(eight.events.map { |e| e['type'] }).not_to include('train_trade_allowed')
  end

  it 'uses the 1867 phase 8 trade-in discounts under Train Trade-in' do
    game = described_class.new(%w[alice bob carol], seed: 1, optional_rules: [:train_trade_in])
    eight = game.depot.trains.find { |t| t.name == '8' }

    expect(eight.discount).to eq('5' => 275, '6' => 325, '7' => 400, '8' => 500,
                                 '2+2' => 300, '5+5E' => 750)
    expect(eight.events.map { |e| e['type'] }).to include('train_trade_allowed')
  end

  it 'opens with a stock round, not an auction' do
    game = described_class.new(%w[alice bob carol], seed: 1)

    expect(game.round).to be_a(Engine::Round::Stock)
  end

  it "has 72 loans, not 1861's 172" do
    game = described_class.new(%w[alice bob carol], seed: 1)

    expect(game.loans.size).to eq(72)
  end
end
