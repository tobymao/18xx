# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1864::Map do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }

  it 'has no duplicate hex ids' do
    ids = described_class::HEXES.values.flat_map(&:keys).flatten
    expect(ids.tally.select { |_id, n| n > 1 }).to eq({})
  end

  it 'names every hex referenced by LOCATION_NAMES' do
    ids = described_class::HEXES.values.flat_map(&:keys).flatten
    expect(described_class::LOCATION_NAMES.keys - ids).to eq([])
  end

  it 'builds every hex without error' do
    expect(game.hexes.size).to eq(described_class::HEXES.values.sum { |h| h.keys.flatten.size })
  end

  it 'names the cities the route bonuses depend on' do
    names = described_class::LOCATION_NAMES.values
    ['Great Lakes', 'Seattle', 'New Orleans', 'Los Angeles', 'St. Louis',
     'San Francisco', 'Chicago', 'Omaha', 'Cheyenne', 'Salt Lake'].each do |city|
      expect(names).to include(city), "no hex named #{city}"
    end
  end

  it 'gives every Canada offboard hex both of its paths and the Canada group' do
    %w[A6 A8 A10 A12 A14 A16 A18].each do |id|
      tile = game.hex_by_id(id).tile

      expect(tile.exits.sort).to eq([0, 5])
      expect(tile.offboards.flat_map(&:groups)).to eq(['Canada'])
    end
  end
end
