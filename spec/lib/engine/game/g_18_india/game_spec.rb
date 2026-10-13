# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18India::Game do
  let(:players) { %w[a b] }

  subject(:game) { Engine::Game::G18India::Game.new(players) }

  def make_stop(location_name)
    tile = double('tile', location_name: location_name)
    double('stop', tile: tile)
  end

  describe '#connection_bonus' do
    # connection_bonus uses the `stops` parameter (paid stops), not visited_stops.
    # A 4E train visits unlimited cities but only pays for 4. This test verifies
    # that the bonus only fires when both pair cities are among the paid stops.

    it 'returns 100 when both Delhi and Kochi are paid stops' do
      stops = [make_stop('DELHI'), make_stop('KOCHI'), make_stop('ALLAHABAD')]
      expect(game.connection_bonus(nil, stops)).to eq(100)
    end

    it 'returns 0 when only one city of the Delhi/Kochi pair is a paid stop' do
      # Simulates a 4E train that visits Kochi but Kochi is not among the 4 paid cities
      stops = [make_stop('DELHI'), make_stop('ALLAHABAD')]
      expect(game.connection_bonus(nil, stops)).to eq(0)
    end

    it 'returns 80 when both Karachi and Chennai are paid stops' do
      stops = [make_stop('KARACHI'), make_stop('CHENNAI')]
      expect(game.connection_bonus(nil, stops)).to eq(80)
    end

    it 'returns 80 when both Lahore and Kolkata are paid stops' do
      stops = [make_stop('LAHORE'), make_stop('KOLKATA')]
      expect(game.connection_bonus(nil, stops)).to eq(80)
    end

    it 'returns 70 when both Nepal and Mumbai are paid stops' do
      stops = [make_stop('NEPAL'), make_stop('MUMBAI')]
      expect(game.connection_bonus(nil, stops)).to eq(70)
    end

    it 'accumulates multiple bonuses when multiple pairs are all paid stops' do
      stops = [make_stop('DELHI'), make_stop('KOCHI'), make_stop('NEPAL'), make_stop('MUMBAI')]
      expect(game.connection_bonus(nil, stops)).to eq(170)
    end
  end
end
