# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE double town tiles (§11.1)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  let(:manifest) do
    {
      'OE1' => [:yellow, 4, [0, 3], 0.0, [1.5, 4.5], 10],
      'OE2' => [:yellow, 6, [0, 4], 0.5, [1.0, 3.0], 10],
      'OE3' => [:yellow, 2, [0, 5], 1.0, [1.0, 4.0], 10],
      'OE9' => [:green, 3, [0, 1, 3, 4], 2.0, [2.0, 5.0], 10],
      'OE10' => [:green, 3, [0, 2, 3, 4], 1.5, [1.0, 5.0], 10],
      'OE11' => [:green, 3, [0, 1, 2, 3], 0.0, [4.0, 5.0], 10],
      'OE20' => [:brown, 3, [0, 1, 2, 3], 0.0, [3.5, 5.5], 20],
      'OE21' => [:brown, 2, [0, 1, 2, 3, 4], 2.0, [0.5, 3.5], 20],
      'OE22' => [:brown, 6, [0, 1, 2, 3, 4, 5], 0.0, [1.5, 4.5], 20],
    }
  end

  let(:two_dot_hexes) { %w[J29 M26 W32 N41 Q46 U64 W46 AF53 J77 P77 AC6 C58 U6 T37 L39] }

  def tile_named(game, name)
    game.tiles.find { |t| t.name == name }
  end

  it 'defines every double-town tile from the Tile Manifest Chart' do
    manifest.each do |name, (color, count, exits, axis, revenue_locs, revenue)|
      tile = tile_named(game, name)
      expect(tile).not_to be_nil, "#{name} missing"
      expect(game.tiles.count { |t| t.name == name }).to eq(count)
      expect(tile.color).to eq(color)
      expect(tile.exits.uniq.sort).to eq(exits)
      expect(tile.double_towns.size).to eq(1)
      double_town = tile.double_towns.first
      expect(double_town.axis).to eq(axis)
      expect(double_town.revenue_locs).to eq(revenue_locs)
      expect(double_town.towns.map(&:max_revenue)).to eq([revenue, revenue])
    end
  end

  it 'prints a double town on every two-dot hex' do
    two_dot_hexes.each do |id|
      tile = game.hex_by_id(id).tile
      expect(tile.double_towns.size).to eq(1)
      expect(tile.towns.size).to eq(2)
    end
  end

  it 'lays double-town tiles only on two-dot hexes (§11.1)' do
    oe1 = tile_named(game, 'OE1')
    expect(game.upgrades_to?(game.hex_by_id('J29').tile, oe1)).to be(true)
    expect(game.upgrades_to?(game.hex_by_id('J29').tile, game.tiles.find { |t| t.name == '4' })).to be(false)
    expect(game.upgrades_to?(game.hex_by_id('H29').tile, oe1)).to be(false)
  end

  it 'upgrades a double town only to another double town' do
    oe1 = tile_named(game, 'OE1')
    oe9 = tile_named(game, 'OE9')
    oe22 = tile_named(game, 'OE22')
    expect(game.upgrades_to?(oe1, oe9)).to be(true)
    expect(game.upgrades_to?(oe9, oe22)).to be(true)
    expect(game.upgrades_to?(oe1, tile_named(game, '141'))).to be(false)
    expect(game.upgrades_to?(tile_named(game, '141'), tile_named(game, 'OE20'))).to be(false)
    separate = Engine::Tile.from_code('2t', 'green', 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:3,b:_1')
    expect(game.upgrades_to?(oe1, separate)).to be(false)
  end
end
