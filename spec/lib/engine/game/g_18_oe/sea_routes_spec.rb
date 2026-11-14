# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE sea routes (§11.3.4, §11.3.6, §11.3.7, §11.3.8)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  def path_at(hex_id, exit)
    game.hex_by_id(hex_id).tile.paths.find { |path| path.exits.include?(exit) }
  end

  describe 'sea traffic (§11.3.8)' do
    it 'paints every ferry with the one ferry colour' do
      colours = game.hexes.flat_map { |hex| hex.tile.paths }.filter_map(&:color).uniq
      expect(colours).to eq([Engine::Game::G18OE::Map::FERRY_TRACK_COLOR])
    end

    it 'treats ferry track and port sections as sea traffic, but not other land track in a sea zone' do
      expect(game.sea_traffic?(game.hex_by_id('N29').tile.paths.first)).to be(true)
      expect(game.sea_traffic?(path_at('M28', 5))).to be(true)
      expect(game.sea_traffic?(path_at('AF25', 3))).to be(true)
      expect(game.sea_traffic?(path_at('T87', 0))).to be(false)
      expect(game.sea_traffic?(path_at('I50', 1))).to be(false)
    end

    it 'does not count a dead-end arrow as a port exit' do
      expect(game.port_exit?('E28', 4)).to be(false)
      expect(game.port_exit?('H55', 4)).to be(true)
    end
  end

  describe 'port token reduction (§11.3.4)' do
    it 'reduces by one through Phase 6 and by two from Phase 7' do
      expect(game.port_token_reduction(double('phase', name: '2'))).to eq(1)
      expect(game.port_token_reduction(double('phase', name: '6'))).to eq(1)
      expect(game.port_token_reduction(double('phase', name: '7'))).to eq(2)
      expect(game.port_token_reduction(double('phase', name: '8'))).to eq(2)
    end
  end

  describe 'ferry links' do
    it 'lists the ferries at an exit and skips ferries to hexes missing from the map' do
      expect(game.ferry_links('I20', 4)).to contain_exactly([['J23', 2], 1], [['J25', 2], 1], [['I26', 1], 1])
      uk_fr = new_game(klass: Engine::Game::G18OEUKFR::Game)
      expect(uk_fr.ferry_links('M28', 5)).to eq([[['N31', 1], 0]])
    end
  end
end
