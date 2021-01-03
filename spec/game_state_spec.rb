# frozen_string_literal: true

require 'find'

require 'engine'
require 'spec_helper'

def game_at_action(game_file, action_id = nil)
  Engine::Game.load(game_file, at_action: action_id).maybe_raise!
end

module Engine
  describe 'Fixture Game State' do
    let(:game_file) do
      Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{described_class}.json" }
    end

    describe '1846' do
      describe 19_962 do
        it 'removes the reservation when a token is placed' do
          game = game_at_action(game_file, 154)
          city = game.hex_by_id('D20').tile.cities.first
          corp = game.corporation_by_id('ERIE')
          expect(city.reserved_by?(corp)).to be(false)
        end

        it 'has correct reservations and tokens after NYC closes' do
          game = game_at_action(game_file, 162)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')

          expect(city.reservations).to eq([nil, nil])
          expect(city.tokens.map { |t| t&.corporation }).to eq([nil, erie])
        end

        it 'has a cert limit of 12 at the start of a 4p game' do
          game = game_at_action(game_file, 0)
          expect(game.cert_limit).to be(12)
        end

        it 'has a cert limit of 10 after a corporation closes' do
          game = game_at_action(game_file, 162)
          expect(game.cert_limit).to be(10)
        end

        it 'has a cert limit of 10 after a corporation closes and then a player is bankrupt' do
          game = game_at_action(game_file, 405)
          expect(game.cert_limit).to be(10)
        end

        it 'has a cert limit of 8 after a corporation closes, then a player is '\
           'bankrupt, and then another corporation closes' do
          game = game_at_action(game_file, 443)
          expect(game.cert_limit).to be(8)
        end
      end
    end

    describe '1846 2p Variant' do
      describe 11_098 do
        it 'has both reservations at the start of the game' do
          game = game_at_action(game_file, 0)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')
          nyc = game.corporation_by_id('NYC')

          expect(city.reservations).to eq([nyc, erie])
        end

        it 'keeps the second slot reserved for ERIE when NYC floats' do
          game = game_at_action(game_file, 11)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')
          nyc = game.corporation_by_id('NYC')

          expect(city.reservations).to eq([nil, erie])
          expect(city.tokens.map { |t| t&.corporation }).to eq([nyc, nil])
        end

        it 'ERIE\'s token does not replace NYC\'s when ERIE uses its reserved spot' do
          game = game_at_action(game_file, 24)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')
          nyc = game.corporation_by_id('NYC')

          expect(city.reservations).to eq([nil, nil])
          expect(city.tokens.map { |t| t&.corporation }).to eq([nyc, erie])
        end
      end
    end
  end
end
