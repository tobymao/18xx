# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1862::Game do
  let(:players) { %w[alice bob carol] }

  def offered_types(game)
    game.depot.trains.flat_map do |train|
      train.variants.keys.reject { |name| name == train.name }.map { |name| game.train_type_by_name(name) }
    end.uniq.sort
  end

  it 'offers all three train types by default' do
    game = described_class.new(players, seed: 1)

    expect(offered_types(game)).to eq(%i[express freight local])
  end

  it 'offers only freight trains in Simple Freight' do
    game = described_class.new(players, seed: 1, optional_rules: [:simple_freight])

    expect(offered_types(game)).to eq([:freight])
  end

  it 'offers only express trains in Simple Express' do
    game = described_class.new(players, seed: 1, optional_rules: [:simple_express])

    expect(offered_types(game)).to eq([:express])
  end

  it 'keeps the same number of depot trains in the simple variants' do
    standard = described_class.new(players, seed: 1)
    simple = described_class.new(players, seed: 1, optional_rules: [:simple_freight])

    expect(simple.depot.trains.size).to eq(standard.depot.trains.size)
  end

  it 'gives every corporation a permit for the only train type' do
    game = described_class.new(players, seed: 1, optional_rules: [:simple_express])

    expect(game.corporations.map { |corp| game.permits[corp] }.uniq).to eq([[:express]])
  end

  it 'keeps the standard per-type train limit by default' do
    game = described_class.new(players, seed: 1)
    corp = game.corporations.first

    expect(game.train_limit_by_type(corp)).to eq(3)
  end

  it 'limits trains in total by phase in the simple variants' do
    game = described_class.new(players, seed: 1, optional_rules: [:simple_freight])

    expect(game.phase.phases.to_h { |phase| [phase[:name], phase[:train_limit]] })
      .to eq('A' => 4, 'B' => 4, 'C' => 4, 'D' => 4, 'E' => 3, 'F' => 3, 'G' => 2, 'H' => 2)
    expect(game.train_limit(game.corporations.first)).to eq(4)
  end

  it 'drops the per-type and total limit statuses in the simple variants' do
    game = described_class.new(players, seed: 1, optional_rules: [:simple_freight])

    expect(game.phase.phases.flat_map { |phase| phase[:status] }.grep(/_(per|total)/)).to be_empty
  end

  it 'offers freight and local trains in Advanced Freight' do
    game = described_class.new(players, seed: 1, optional_rules: [:advanced_freight])

    expect(offered_types(game)).to eq(%i[freight local])
  end

  it 'offers express and local trains in Advanced Express' do
    game = described_class.new(players, seed: 1, optional_rules: [:advanced_express])

    expect(offered_types(game)).to eq(%i[express local])
  end

  it 'deals 8 freight and 8 local permits in Advanced Freight' do
    game = described_class.new(%w[a b c d], seed: 1, optional_rules: [:advanced_freight])

    expect(game.corporations.flat_map { |corp| game.permits[corp] }.tally).to eq(freight: 8, local: 8)
  end

  it 'deals 8 express and 8 local permits in Advanced Express' do
    game = described_class.new(%w[a b c d], seed: 1, optional_rules: [:advanced_express])

    expect(game.corporations.flat_map { |corp| game.permits[corp] }.tally).to eq(express: 8, local: 8)
  end

  it 'limits trains by type in the advanced variants, with the total before phase G' do
    game = described_class.new(players, seed: 1, optional_rules: [:advanced_freight])
    corp = game.corporations.first

    expect(game.train_limit_by_type(corp)).to eq(3)
    expect(game.train_limit(corp)).to eq(6)
  end

  it 'rejects two train rules together' do
    expect { described_class.new(players, seed: 1, optional_rules: %i[advanced_freight simple_express]) }
      .to raise_error(Engine::GameError, /Only one train rule/)
  end
end
