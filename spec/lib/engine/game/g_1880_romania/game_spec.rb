# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1880Romania::Game do
  let(:map) { Engine::Game::G1880Romania::Map }

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
end
