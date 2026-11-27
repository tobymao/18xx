# frozen_string_literal: true

require './spec/spec_helper'

module Engine
  describe Game::G1833NE::Game do
    subject(:game) { described_class.new(%w[a b c]) }

    let(:train) { double(name: '4', distance: 4, multiplier: nil) }
    let(:phases) { described_class::PHASES.map { |p| double(name: p[:name], tiles: p[:tiles]) } }
    let(:offboards) { game.hexes.flat_map { |hex| hex.tile.offboards } }

    it 'defines a revenue for every off-board in every phase' do
      expect(offboards).not_to be_empty
      offboards.product(phases).each do |offboard, phase|
        expect { offboard.route_revenue(phase, train) }.not_to raise_error
      end
    end

    it 'pays the phase I value through phase II and the phase III value through phase IV' do
      dh_rr = game.hex_by_id('A12').tile.offboards.first
      expect(phases.map { |phase| dh_rr.route_revenue(phase, train) }).to eq([40, 40, 70, 70, 80])
    end

    it 'colors the nav bar for the off-board phases as well as the tile phases' do
      colors = [game.nav_bar_color]
      (phases.size - 1).times do
        game.phase.next!
        colors << game.nav_bar_color
      end

      expect(colors).to eq([:yellow, :green, described_class::MINT, :brown, described_class::TAN])
    end
  end
end
