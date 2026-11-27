# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G18PA::Step::Track do
    let(:game) { Game::G18PA::Game.new(%w[A B C], id: 1) }

    def track_for(minor_id)
      company = game.company_by_id("P#{minor_id}")
      game.after_buy_company(game.players.first, company, 110)
      minor = game.minor_for(company)
      round = game.operating_round(1)
      [minor, round.steps.grep(described_class).first]
    end

    def lay(entity, hex, tile_name, rotation)
      tile = game.tiles.find { |candidate| candidate.name == tile_name }
      Action::LayTile.new(entity, hex: hex, tile: tile, rotation: rotation)
    end

    it 'allows one free yellow tile in phase 2' do
      minor, step = track_for('5')
      islip = game.hex_by_id('H21')

      expect(step.upgradeable_tiles(minor, islip).map(&:name)).to include('4')
      step.process_lay_tile(lay(minor, islip, '4', 1))

      expect(islip.tile.name).to eq('4')
      expect(step.can_lay_tile?(minor)).to be(false)
      expect(minor.cash).to eq(0)
    end

    it 'offers a free green upgrade only once green is available' do
      minor, step = track_for('2')
      auburn = game.hex_by_id('B5')
      action = lay(minor, auburn, '15', 4)

      expect(step.upgradeable_tiles(minor, auburn)).to be_empty
      expect { step.process_lay_tile(action) }.to raise_error(GameError, /upgrade to green when available/)

      game.phase.next!
      expect(step.upgradeable_tiles(minor, auburn).map(&:name)).to include('15')
      step.process_lay_tile(action)

      expect(auburn.tile.name).to eq('15')
      expect(step.can_lay_tile?(minor)).to be(false)
    end

    it 'rejects terrain costs even for a private company with enough cash' do
      minor, step = track_for('8')
      yonkers = game.hex_by_id('G20')
      game.bank.spend(100, minor)
      before = yonkers.tile

      expect(step.available_hex(minor, yonkers)).to be_nil
      expect { step.process_lay_tile(lay(minor, yonkers, '4', 0)) }.to raise_error(GameError, /without a cost/)
      expect(yonkers.tile).to equal(before)
      expect(minor.cash).to eq(100)
    end

    it 'rejects rotations that complete a paid river crossing' do
      minor, step = track_for('1')
      hex = game.hex_by_id('D19')
      game.bank.spend(100, minor)
      before = hex.tile

      expect(step.available_hex(minor, hex)).not_to be_nil
      expect(step.upgradeable_tiles(minor, hex)).to be_empty
      expect { step.process_lay_tile(lay(minor, hex, '8', 5)) }.to raise_error(GameError, /without a cost/)
      expect(hex.tile).to equal(before)
      expect(minor.cash).to eq(100)
    end
  end
end
