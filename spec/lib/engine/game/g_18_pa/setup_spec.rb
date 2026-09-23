# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G18PA::Game do
    let(:game) { described_class.new(%w[A B C], id: 1) }

    it 'uses a two-train limit in every phase' do
      expect(described_class::PHASES.map { |phase| phase[:train_limit] }).to eq([2, 2, 2, 2, 2])
    end

    it 'identifies Worcester on D25' do
      expect(game.hex_by_id('D25').location_name).to eq('Worcester')
    end

    it 'allows Baltimore to upgrade to its green BAL tile' do
      baltimore = game.hex_by_id('K10').tile
      green = game.tiles.find { |tile| tile.name == 'X14' }
      expect(game.upgrades_to?(baltimore, green)).to be true
    end

    it 'gives each of the nine minors its own reserved, unbuyable 2-train' do
      minors = game.corporations.select { |corporation| corporation.type == :minor }
      expect(minors.size).to eq(9)
      minors.each do |minor|
        expect(minor.trains).to contain_exactly(
          have_attributes(name: '2', owner: minor, reserved: true, buyable: false),
        )
      end
      expect(minors.flat_map(&:trains).uniq.size).to eq(9)
    end

    it 'gives NYC a reserved, unbuyable 3-train' do
      nyc = game.corporation_by_id('NYC')
      expect(nyc.trains).to contain_exactly(
        have_attributes(name: '3', owner: nyc, reserved: true, buyable: false),
      )
    end

    it 'leaves five 2-trains and four 3-trains in the depot, in that order' do
      expect(game.depot.upcoming.count { |train| train.name == '2' }).to eq(5)
      expect(game.depot.upcoming.count { |train| train.name == '3' }).to eq(4)
      expect(game.depot.depot_trains.map(&:name)).to eq(['2'])

      game.depot.export_all!('2')
      expect(game.depot.depot_trains.map(&:name)).to eq(['3'])

      game.depot.export_all!('3')
      expect(game.depot.depot_trains.map(&:name)).to eq(['4'])
      expect(game.corporation_by_id('NYC').trains.map(&:name)).to eq(['3'])
    end

    it 'keeps starting trains out of both depot and intercompany sales' do
      starting_trains = game.corporations.flat_map(&:trains)
      expect(starting_trains.size).to eq(10)
      expect(game.depot.upcoming & starting_trains).to be_empty

      game.corporations.each { |corporation| corporation.owner = game.players.first }
      expect(game.depot.other_trains(game.corporation_by_id('PRR'))).to be_empty
    end

    it 'allocates starting trains without spending cash or advancing the phase' do
      expect(game.corporations.map(&:cash)).to all(eq(0))
      expect(game.bank.cash).to eq(6_500)
      expect(game.phase.name).to eq('2')
    end
  end
end
