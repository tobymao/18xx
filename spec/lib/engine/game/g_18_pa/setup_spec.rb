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
  end
end
